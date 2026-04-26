export interface ProductOption {
  value: string;
  label: string;
  aliases: string[];
}

export const MATERIAL_TYPE_OPTIONS: ProductOption[] = [
  { value: "gold", label: "Gold", aliases: ["gold", "1"] },
  { value: "silver", label: "Silver", aliases: ["silver", "2"] },
  { value: "diamond", label: "Diamond", aliases: ["diamond", "3"] },
];

export const PRODUCT_FORM_OPTIONS: ProductOption[] = [
  { value: "jewelry", label: "Jewelry", aliases: ["jewelry", "1"] },
  { value: "coin", label: "Coin", aliases: ["coin", "2"] },
  { value: "bar", label: "Bar", aliases: ["bar", "3"] },
  { value: "other", label: "Other", aliases: ["other", "0", "4", ""] },
];

export const normalizeMaterialTypeKey = (value: string | undefined) => {
  const raw = String(value ?? "").trim().toLowerCase();
  return MATERIAL_TYPE_OPTIONS.find((option) => option.aliases.includes(raw))?.value ?? "other";
};

export const normalizeProductFormKey = (value: string | undefined) => {
  const raw = String(value ?? "").trim().toLowerCase();
  return PRODUCT_FORM_OPTIONS.find((option) => option.aliases.includes(raw))?.value ?? "other";
};
