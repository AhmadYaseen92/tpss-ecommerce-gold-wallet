export function statusClass(status: string) {
  const normalized = status.toLowerCase();
  if (normalized.includes("approved") || normalized.includes("active")) return "status-green";
  if (normalized.includes("rejected") || normalized.includes("inactive")) return "status-red";
  return "status-orange";
}
