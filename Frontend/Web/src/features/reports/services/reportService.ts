import type { Invoice, Investor, InvestorRequest, Product } from "../../../shared/types/models";
import type { ReportFilters } from "../types/reportTypes";

export interface ReportCriteria extends ReportFilters {
  start: Date;
  end: Date;
}

function inDateRange(value: string | undefined, start: Date, end: Date) {
  if (!value) return true;
  const at = new Date(value);
  return at >= start && at <= end;
}

function includesCase(haystack: string | undefined, needle: string) {
  if (!needle) return true;
  return (haystack ?? "").toLowerCase().includes(needle.toLowerCase());
}

function normalizeMaterialType(value: string | undefined) {
  const raw = String(value ?? "").trim().toLowerCase();
  if (raw === "1" || raw === "gold") return "gold";
  if (raw === "2" || raw === "silver") return "silver";
  if (raw === "3" || raw === "diamond") return "diamond";
  return "other";
}

function normalizeFormType(value: string | undefined) {
  const raw = String(value ?? "").trim().toLowerCase();
  if (raw === "1" || raw === "jewelry") return "jewelry";
  if (raw === "2" || raw === "coin") return "coin";
  if (raw === "3" || raw === "bar") return "bar";
  return "other";
}

export const reportService = {
  makeCriteria(filters: ReportFilters): ReportCriteria {
    const now = new Date();
    const start = new Date(now);
    const end = new Date(now);

    if (filters.datePreset === "today") {
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
    } else if (filters.datePreset === "yesterday") {
      start.setDate(now.getDate() - 1);
      end.setDate(now.getDate() - 1);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
    } else if (filters.datePreset === "thisWeek") {
      const day = now.getDay();
      const diff = day === 0 ? 6 : day - 1;
      start.setDate(now.getDate() - diff);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
    } else if (filters.datePreset === "thisMonth") {
      start.setDate(1);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);
    } else if (filters.customFrom || filters.customTo) {
      const from = filters.customFrom ? new Date(filters.customFrom) : now;
      const to = filters.customTo ? new Date(filters.customTo) : now;
      from.setHours(0, 0, 0, 0);
      to.setHours(23, 59, 59, 999);
      return { ...filters, start: from, end: to };
    }

    return { ...filters, start, end };
  },

  matchRequest(request: InvestorRequest, criteria: ReportCriteria, investors: Map<string, Investor>) {
    const investor = investors.get(request.investorId);
    return inDateRange(request.createdAt, criteria.start, criteria.end)
      && (criteria.investorId === "all" || request.investorId === criteria.investorId)
      && (criteria.productId === "all" || includesCase(request.productName, criteria.productId))
      && (criteria.materialType === "all" || normalizeMaterialType(request.category) === criteria.materialType)
      && (criteria.formType === "all" || includesCase(request.productName, criteria.formType))
      && (criteria.requestType === "all" || request.type === criteria.requestType)
      && (criteria.transactionStatus === "all" || request.status === criteria.transactionStatus)
      && (criteria.walletActionType === "all" || request.type === criteria.walletActionType)
      && includesCase(request.id, criteria.orderNumber)
      && includesCase(request.investorName, criteria.userName)
      && includesCase(investor?.phoneNumber, criteria.phone)
      && includesCase(investor?.email, criteria.email);
  },

  matchProduct(product: Product, criteria: ReportCriteria) {
      return inDateRange(product.updatedAt, criteria.start, criteria.end)
      && (criteria.productId === "all" || product.id === criteria.productId)
      && (criteria.materialType === "all" || normalizeMaterialType(product.materialType || product.category) === criteria.materialType)
      && (criteria.formType === "all" || normalizeFormType(product.formType) === criteria.formType);
  },

  matchInvoice(invoice: Invoice, criteria: ReportCriteria) {
    return inDateRange(invoice.issuedAt, criteria.start, criteria.end)
      && (criteria.paymentStatus === "all" || invoice.paymentStatus === criteria.paymentStatus)
      && includesCase(invoice.id, criteria.invoiceNumber)
      && includesCase(invoice.investorName, criteria.userName);
  },

  matchInvestor(investor: Investor, criteria: ReportCriteria) {
    return (criteria.investorId === "all" || investor.id === criteria.investorId)
      && includesCase(investor.fullName, criteria.userName)
      && includesCase(investor.phoneNumber, criteria.phone)
      && includesCase(investor.email, criteria.email);
  },

  compareBy(a: Record<string, string | number>, b: Record<string, string | number>, key: string, dir: "asc" | "desc") {
    const left = a[key] ?? "";
    const right = b[key] ?? "";
    const mul = dir === "asc" ? 1 : -1;
    if (typeof left === "number" && typeof right === "number") return (left - right) * mul;
    return String(left).localeCompare(String(right)) * mul;
  },

  buildTotalsRow(headers: string[], rows: Array<Record<string, string | number>>) {
    const totals: Record<string, string | number> = {};
    headers.forEach((header, index) => {
      if (index === 0) {
        totals[header] = "Totals";
        return;
      }
      const total = rows.reduce((sum, row) => sum + (typeof row[header] === "number" ? Number(row[header]) : 0), 0);
      totals[header] = total > 0 ? Number(total.toFixed(2)) : "-";
    });
    return totals;
  },

  dateLabel(value: string | undefined) {
    if (!value) return "-";
    return new Date(value).toLocaleDateString();
  },

  diffHours(from: string, to: string) {
    const first = new Date(from).getTime();
    const second = new Date(to).getTime();
    return Number(((second - first) / (1000 * 60 * 60)).toFixed(1));
  },

  toDelimited(headers: string[], rows: Array<Record<string, string | number>>, delimiter: string) {
    return [headers.join(delimiter), ...rows.map((row) => headers.map((header) => JSON.stringify(row[header] ?? "")).join(delimiter))].join("\n");
  }
};
