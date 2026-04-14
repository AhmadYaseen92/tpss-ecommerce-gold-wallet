import { ref } from "vue";

export function useReports() {
  const generatedRows = ref<Array<Record<string, string | number>>>([]);
  return { generatedRows };
}
