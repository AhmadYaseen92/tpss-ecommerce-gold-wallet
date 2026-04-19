import { onMounted, onUnmounted } from "vue";
import { getSignalRConnection } from "./signalrClient";

interface UseRealtimeSyncOptions {
  onProductUpdate?: () => void | Promise<void>;
  onDashboardUpdate?: () => void | Promise<void>;
  onTransactionUpdate?: () => void | Promise<void>;
  onWalletUpdate?: () => void | Promise<void>;
  token?: string;
}

export function useRealtimeSync(options: UseRealtimeSyncOptions) {
  let connection: any = null;

  const handleEvent = async (event: string) => {
    if (event === "product" && options.onProductUpdate) await options.onProductUpdate();
    if (event === "dashboard" && options.onDashboardUpdate) await options.onDashboardUpdate();
    if (event === "transaction" && options.onTransactionUpdate) await options.onTransactionUpdate();
    if (event === "wallet" && options.onWalletUpdate) await options.onWalletUpdate();
  };

  onMounted(async () => {
    if (!options.token) return;
    connection = getSignalRConnection(options.token, handleEvent);
    try {
      await connection.start();
    } catch (e) {
      // Optionally handle connection errors
    }
  });

  onUnmounted(async () => {
    if (connection) {
      try {
        await connection.stop();
      } catch {}
      connection = null;
    }
  });
}
