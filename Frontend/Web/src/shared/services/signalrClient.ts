export interface LightweightSignalRConnection {
  on(eventName: string, handler: (payload: unknown) => void): void;
  start(): Promise<void>;
  stop(): Promise<void>;
}

let handlers: Record<string, Array<(payload: unknown) => void>> = {};

const connection: LightweightSignalRConnection = {
  on(eventName, handler) {
    handlers[eventName] = handlers[eventName] ?? [];
    handlers[eventName].push(handler);
  },
  async start() {
    // No-op fallback client used when @microsoft/signalr dependency is unavailable.
  },
  async stop() {
    handlers = {};
  }
};

export function getSignalRConnection(_token: string, onEvent: (event: string, payload: unknown) => void) {
  connection.on("ProductUpdated", (payload: unknown) => onEvent("product", payload));
  connection.on("DashboardUpdated", (payload: unknown) => onEvent("dashboard", payload));
  connection.on("TransactionUpdated", (payload: unknown) => onEvent("transaction", payload));
  connection.on("WalletUpdated", (payload: unknown) => onEvent("wallet", payload));
  return connection;
}
