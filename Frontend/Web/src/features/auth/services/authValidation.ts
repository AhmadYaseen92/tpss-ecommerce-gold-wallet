export const EMAIL_REGEX = /^\S+@\S+\.\S+$/;
export const UAE_MOBILE_REGEX = /^(?:\+971|0)?5\d{8}$/;
export const INTERNATIONAL_PHONE_REGEX = /^\+?[1-9]\d{7,14}$/;
export const NUMERIC_ONLY_REGEX = /^\d+$/;
export const IBAN_REGEX = /^[A-Z]{2}\d{2}[A-Z0-9]{10,30}$/;
export const SWIFT_REGEX = /^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/;

export const isEmail = (value: string) => EMAIL_REGEX.test(value.trim());
export const isUaeMobile = (value: string) => UAE_MOBILE_REGEX.test(value.trim());
export const isInternationalPhone = (value: string) => INTERNATIONAL_PHONE_REGEX.test(value.trim().replace(/[\s-]/g, ""));
export const isNumericOnly = (value: string) => NUMERIC_ONLY_REGEX.test(value.trim());
export const isValidIban = (value: string) => IBAN_REGEX.test(value.trim().toUpperCase().replace(/\s+/g, ""));
export const isValidSwift = (value: string) => SWIFT_REGEX.test(value.trim().toUpperCase());
