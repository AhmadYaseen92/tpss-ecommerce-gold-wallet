export type MarketplaceRefreshHandler = (reason: string) => void;

type StartOptions = {
  accessTokenFactory: () => string;
  onRefreshRequested: MarketplaceRefreshHandler;
  onConnectionStateChanged: (isConnected: boolean) => void;
};

type SignalRConnection = {
  start: () => Promise<void>;
  stop: () => Promise<void>;
  on: (event: string, callback: (payload: { reason?: string }) => void) => void;
  off: (event: string) => void;
  onreconnected: (callback: () => void) => void;
  onreconnecting: (callback: () => void) => void;
  onclose: (callback: () => void) => void;
  state?: string | number;
};

type SignalRGlobal = {
  HubConnectionBuilder: new () => {
    withUrl: (url: string, options: { accessTokenFactory: () => string }) => any;
    withAutomaticReconnect: (delays: number[]) => any;
    configureLogging: (level: unknown) => any;
    build: () => SignalRConnection;
  };
  LogLevel: { Warning: unknown };
  HubConnectionState?: { Disconnected: string | number };
};

declare global {
  interface Window {
    signalR?: SignalRGlobal;
  }
}

const SIGNALR_CDN = "https://cdn.jsdelivr.net/npm/@microsoft/signalr@9.0.4/dist/browser/signalr.min.js";

async function ensureSignalRLoaded(): Promise<SignalRGlobal | null> {
  if (typeof window === "undefined") return null;
  if (window.signalR) return window.signalR;

  await new Promise<void>((resolve, reject) => {
    const existing = document.querySelector(`script[data-signalr='true']`) as HTMLScriptElement | null;
    if (existing) {
      if (window.signalR) {
        resolve();
        return;
      }

      existing.addEventListener("load", () => resolve(), { once: true });
      existing.addEventListener("error", () => reject(new Error("failed to load signalr")), { once: true });
      return;
    }

    const script = document.createElement("script");
    script.src = SIGNALR_CDN;
    script.async = true;
    script.dataset.signalr = "true";
    script.addEventListener("load", () => resolve(), { once: true });
    script.addEventListener("error", () => reject(new Error("failed to load signalr")), { once: true });
    document.head.appendChild(script);
  });

  return window.signalR ?? null;
}

function isConnectionDisconnected(connection: SignalRConnection, signalR: SignalRGlobal | null): boolean {
  const disconnectedState = signalR?.HubConnectionState?.Disconnected;
  if (typeof disconnectedState !== "undefined") {
    return connection.state === disconnectedState;
  }

  return connection.state === "Disconnected" || connection.state === 0;
}

export class MarketplaceRealtime {
  private connection: SignalRConnection | null = null;

  async start(options: StartOptions): Promise<void> {
    const signalR = await ensureSignalRLoaded().catch(() => null);
    if (!signalR) {
      options.onConnectionStateChanged(false);
      return;
    }

    if (this.connection && !isConnectionDisconnected(this.connection, signalR)) {
      return;
    }

    const connection = new signalR.HubConnectionBuilder()
      .withUrl(`${import.meta.env.VITE_API_BASE_URL ?? "http://localhost:5055"}/hubs/marketplace`, {
        accessTokenFactory: options.accessTokenFactory
      })
      .withAutomaticReconnect([0, 1000, 3000, 5000])
      .configureLogging(signalR.LogLevel.Warning)
      .build();

    this.connection = connection;

    connection.off("MarketplaceRefreshRequested");
    connection.on("MarketplaceRefreshRequested", (payload: { reason?: string }) => {
      options.onRefreshRequested(payload?.reason ?? "signalr");
    });

    connection.onreconnected(() => {
      options.onConnectionStateChanged(true);
      options.onRefreshRequested("reconnected");
    });
    connection.onreconnecting(() => options.onConnectionStateChanged(false));
    connection.onclose(() => options.onConnectionStateChanged(false));

    try {
      await connection.start();
      options.onConnectionStateChanged(true);
      options.onRefreshRequested("connected");
    } catch {
      options.onConnectionStateChanged(false);
    }
  }

  async stop(): Promise<void> {
    if (!this.connection) return;
    try {
      await this.connection.stop();
    } finally {
      this.connection = null;
    }
  }
}
