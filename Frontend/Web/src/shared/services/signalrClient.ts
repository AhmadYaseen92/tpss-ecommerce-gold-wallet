import { HubConnectionBuilder, LogLevel, HubConnection } from "@microsoft/signalr";

let connection: HubConnection | null = null;

export function getSignalRConnection(token: string, onEvent: (event: string, payload: any) => void) {
  if (connection) return connection;
  connection = new HubConnectionBuilder()
    .withUrl("/hubs/updates", { accessTokenFactory: () => token })
    .configureLogging(LogLevel.Information)
    .withAutomaticReconnect()
    .build();

  connection.on("ProductUpdated", (payload) => onEvent("product", payload));
  connection.on("DashboardUpdated", (payload) => onEvent("dashboard", payload));
  connection.on("TransactionUpdated", (payload) => onEvent("transaction", payload));
  connection.on("WalletUpdated", (payload) => onEvent("wallet", payload));

  return connection;
}
