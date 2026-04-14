export const reportService = {
  toPdfText(rows: Array<Record<string, string | number>>) {
    return rows.map((row) => Object.entries(row).map(([k, v]) => `${k}: ${v}`).join(" | ")).join("\n");
  }
};
