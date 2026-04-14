export const investorService = {
  toggleStatus(current: string): string {
    return current === "active" ? "inactive" : "active";
  }
};
