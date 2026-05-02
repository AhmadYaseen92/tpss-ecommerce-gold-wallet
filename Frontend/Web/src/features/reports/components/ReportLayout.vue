<script setup lang="ts">
import { onBeforeUnmount, ref } from "vue";
import MetricGrid from "../../../shared/components/MetricGrid.vue";
import type { ReportMetric } from "../../../shared/types/models";
import type { ReportTableData } from "../types/reportTypes";
import LoadingState from "../../../shared/components/ui/LoadingState.vue";
import EmptyState from "../../../shared/components/ui/EmptyState.vue";
import Pagination from "../../../shared/components/ui/Pagination.vue";

defineProps<{
  title: string;
  loading: boolean;
  empty: boolean;
  summaryMetrics: ReportMetric[];
  table: ReportTableData;
  page: number;
  totalPages: number;
}>();

const emit = defineEmits<{ sort: [key: string]; page: [delta: number] }>();

const selectedInvoiceUrl = ref<string | null>(null);
const selectedInvoiceName = ref("invoice.pdf");
const invoiceViewerError = ref("");

const isUrlValue = (value: unknown) => {
  if (typeof value !== "string") return false;
  if (value === "-") return false;
  return value.startsWith("http://") || value.startsWith("https://") || value.startsWith("/");
};

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL ?? "http://localhost:5095").replace(/\/$/, "");

const toAbsoluteUrl = (value: string) => {
  if (value.startsWith("http://") || value.startsWith("https://")) return value;
  return `${API_BASE_URL}${value.startsWith("/") ? value : `/${value}`}`;
};

const SESSION_STORAGE_KEY = "goldwallet.web.session";

const readAccessToken = () => {
  if (typeof window === "undefined") return "";
  const raw = window.localStorage.getItem(SESSION_STORAGE_KEY) ?? window.sessionStorage.getItem(SESSION_STORAGE_KEY);
  if (!raw) return "";
  try {
    const parsed = JSON.parse(raw) as { accessToken?: string };
    return parsed.accessToken ?? "";
  } catch {
    return "";
  }
};

const openInvoiceViewer = async (value: string) => {
  const fileUrl = toAbsoluteUrl(value);
  const accessToken = readAccessToken();

  const response = await fetch(fileUrl, {
    method: "GET",
    headers: accessToken ? { Authorization: `Bearer ${accessToken}` } : undefined
  });

  if (!response.ok) {
    throw new Error("Failed to open invoice template.");
  }

  const fileBlob = await response.blob();
  if (selectedInvoiceUrl.value?.startsWith("blob:")) {
    URL.revokeObjectURL(selectedInvoiceUrl.value);
  }

  const pathPart = value.split("/").filter(Boolean).pop();
  selectedInvoiceName.value = pathPart || "invoice.pdf";
  selectedInvoiceUrl.value = URL.createObjectURL(fileBlob);
};

const closeInvoiceViewer = () => {
  if (selectedInvoiceUrl.value?.startsWith("blob:")) {
    URL.revokeObjectURL(selectedInvoiceUrl.value);
  }
  selectedInvoiceUrl.value = null;
};

onBeforeUnmount(() => {
  closeInvoiceViewer();
});

const handleOpenInvoiceViewer = async (value: string) => {
  try {
    invoiceViewerError.value = "";
    await openInvoiceViewer(value);
  } catch (e) {
    invoiceViewerError.value = e instanceof Error ? e.message : "Failed to open invoice template.";
  }
};

</script>

<template>
  <div class="dashboard-screen">
    <h3>{{ title }}</h3>
    <p v-if="invoiceViewerError" style="color:#b42318;margin:0 0 8px;">{{ invoiceViewerError }}</p>
    <MetricGrid :metrics="summaryMetrics" />

    <LoadingState v-if="loading" />
    <EmptyState v-else-if="empty" message="No records found for the current filters." />
    <div v-else class="ui-table-wrap">
      <table>
        <thead>
          <tr>
            <th v-for="header in table.headers" :key="header">
              <button class="ui-btn ui-btn--ghost" @click="emit('sort', header)">{{ header }}</button>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, rowIndex) in table.rows" :key="rowIndex">
            <td v-for="header in table.headers" :key="`${rowIndex}-${header}`">
              <template v-if="header === 'Invoice Template' && isUrlValue(row[header])">
                <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                  <button class="invoice-thumbnail-btn" @click="handleOpenInvoiceViewer(String(row[header]))" title="View invoice template">
                    <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='64' height='64' viewBox='0 0 24 24' fill='none' stroke='%23b08d3b' stroke-width='1.7' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/%3E%3Cpath d='M14 2v6h6'/%3E%3Cpath d='M8 13h8'/%3E%3Cpath d='M8 17h8'/%3E%3C/svg%3E" alt="Invoice template" />
                  </button>
                </div>
              </template>
              <template v-else>{{ row[header] ?? "-" }}</template>
            </td>
          </tr>
          <tr class="totals-row">
            <td v-for="header in table.headers" :key="`total-${header}`">{{ table.totalsRow[header] ?? "" }}</td>
          </tr>
        </tbody>
      </table>
      <Pagination
        :page="page"
        :total-pages="totalPages"
        :total-items="table.rows.length"
        :page-size="table.rows.length || 1"
        @prev="emit('page', -1)"
        @next="emit('page', 1)"
      />
    </div>

    <div v-if="selectedInvoiceUrl" class="common-modal-overlay" @click.self="closeInvoiceViewer">
      <div class="common-modal document-modal">
        <div class="document-modal-header">
          <h3>Invoice Template</h3>
          <div style="display:flex;gap:10px;align-items:center;">
            <a :href="selectedInvoiceUrl" target="_blank" rel="noopener">Open in new tab</a>
            <a :href="selectedInvoiceUrl" :download="selectedInvoiceName">Download</a>
            <button class="ui-btn ui-btn--ghost" @click="closeInvoiceViewer">Close</button>
          </div>
        </div>
        <div class="viewer-wrap">
          <iframe :src="selectedInvoiceUrl" title="Invoice template viewer" class="viewer-frame" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.invoice-thumbnail-btn { border: 1px solid #ddd1b2; border-radius: 8px; background: #fff; padding: 4px; cursor: pointer; }
.invoice-thumbnail-btn img { width: 44px; height: 44px; object-fit: contain; display: block; }
.document-modal { width: min(1000px, 96vw); max-height: 92vh; }
.document-modal-header { display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; border-bottom: 1px solid #e9dfcc; }
.viewer-wrap { padding: 12px; }
.viewer-frame { width: 100%; height: 75vh; border: 1px solid #e9dfcc; border-radius: 10px; }
</style>
