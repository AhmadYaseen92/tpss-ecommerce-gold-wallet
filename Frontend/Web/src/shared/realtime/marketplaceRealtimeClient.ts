export interface MarketplaceRealtimeEvent {
  entity: string;
  action: string;
  itemId?: string;
  userId?: number;
  sellerId?: number;
  occurredAtUtc?: string;
  metadata?: Record<string, string>;
}

interface RealtimeClientOptions {
  accessToken: string;
  onEvent: (event: MarketplaceRealtimeEvent) => void;
  onAvailabilityChange: (isRealtimeAvailable: boolean) => void;
}

export interface MarketplaceRealtimeClient {
  start: () => Promise<void>;
  stop: () => Promise<void>;
}

interface SignalRConnection {
  start(): Promise<void>;
  stop(): Promise<void>;
  on(methodName: string, callback: (payload: MarketplaceRealtimeEvent) => void): void;
  onreconnecting(callback: () => void): void;
  onreconnected(callback: () => void): void;
  onclose(callback: () => void): void;
  state: string;
}

declare global {
  interface Window {
    signalR?: {
      HubConnectionBuilder: new () => {
        withUrl: (url: string, options: { accessTokenFactory: () => string; withCredentials: boolean }) => any;
        withAutomaticReconnect: (retryDelays: number[]) => any;
        configureLogging: (level: number) => any;
        build: () => SignalRConnection;
      };
      LogLevel: { Warning: number };
    };
  }
}

const resolveHubUrl = () => {
  const rawBaseUrl = (import.meta.env.VITE_API_BASE_URL as string | undefined)?.replace(/\/$/, "") ?? "http://localhost:5107";
  const baseUrl = rawBaseUrl.startsWith("http") ? rawBaseUrl : `${window.location.origin}${rawBaseUrl.startsWith("/") ? "" : "/"}${rawBaseUrl}`;
  return `${baseUrl}/hubs/marketplace`;
};

export function createMarketplaceRealtimeClient(options: RealtimeClientOptions): MarketplaceRealtimeClient {
  const signalR = window.signalR;

  if (!signalR) {
    return {
      start: async () => options.onAvailabilityChange(false),
      stop: async () => options.onAvailabilityChange(false)
    };
  }

  const connection: SignalRConnection = new signalR.HubConnectionBuilder()
    .withUrl(resolveHubUrl(), {
      accessTokenFactory: () => options.accessToken,
      withCredentials: true
    })
    .withAutomaticReconnect([0, 1000, 3000, 5000, 10000, 30000])
    .configureLogging(signalR.LogLevel.Warning)
    .build();

  connection.on("marketplaceEvent", (event: MarketplaceRealtimeEvent) => {
    options.onEvent(event);
    if (typeof window !== "undefined") {
      window.dispatchEvent(new CustomEvent<MarketplaceRealtimeEvent>("marketplace-realtime-event", { detail: event }));
    }
  });

  connection.onreconnecting(() => options.onAvailabilityChange(false));
  connection.onreconnected(() => options.onAvailabilityChange(true));
  connection.onclose(() => options.onAvailabilityChange(false));

  return {
    start: async () => {
      if (connection.state === "Connected" || connection.state === "Connecting") return;
      try {
        await connection.start();
        options.onAvailabilityChange(true);
      } catch {
        options.onAvailabilityChange(false);
      }
    },
    stop: async () => {
      options.onAvailabilityChange(false);
      if (connection.state === "Disconnected") return;
      await connection.stop();
    }
  };
}
