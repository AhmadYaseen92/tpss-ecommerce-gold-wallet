import type { ApiResponse } from "../types/apiTypes";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:5095";
const GLOBAL_ERROR_MESSAGE = "Something went wrong, please contact system Admin.";

export class HttpError extends Error {
  constructor(message: string, public readonly statusCode?: number) {
    super(message);
  }
}

function buildHeaders(accessToken?: string, isJson = true): HeadersInit {
  return {
    ...(isJson ? { "Content-Type": "application/json" } : {}),
    ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {})
  };
}

function isWrappedApiResponse<T>(value: unknown): value is ApiResponse<T> {
  if (typeof value !== "object" || value === null) return false;
  const record = value as Record<string, unknown>;
  return "success" in record || "Success" in record;
}

function getStringValueCaseInsensitive(record: Record<string, unknown>, key: string): string | undefined {
  const direct = record[key];
  if (typeof direct === "string" && direct.trim()) return direct.trim();
  const foundEntry = Object.entries(record).find(([k]) => k.toLowerCase() === key.toLowerCase());
  const foundValue = foundEntry?.[1];
  if (typeof foundValue === "string" && foundValue.trim()) return foundValue.trim();
  return undefined;
}

function getCaseInsensitiveValue(record: Record<string, unknown>, key: string): unknown {
  if (key in record) return record[key];
  const foundEntry = Object.entries(record).find(([k]) => k.toLowerCase() === key.toLowerCase());
  return foundEntry?.[1];
}

function extractMessageFromUnknown(value: unknown): string | undefined {
  if (!value || typeof value !== "object") return undefined;

  const asRecord = value as Record<string, unknown>;

  const message = getStringValueCaseInsensitive(asRecord, "message");
  if (message) return message;
  const title = getStringValueCaseInsensitive(asRecord, "title");
  if (title) return title;
  const detail = getStringValueCaseInsensitive(asRecord, "detail");
  if (detail) return detail;

  const errors = getCaseInsensitiveValue(asRecord, "errors");
  if (Array.isArray(errors) && errors.length > 0) {
    const allErrors = errors
      .filter((item): item is string => typeof item === "string" && item.trim().length > 0)
      .map((item) => item.trim());
    if (allErrors.length > 0) return allErrors.join(" | ");
  }

  if (errors && typeof errors === "object") {
    const collectedErrors = Object.entries(errors as Record<string, unknown>)
      .flatMap(([field, entry]) => {
        if (!Array.isArray(entry)) return [];
        return entry
          .filter((item): item is string => typeof item === "string" && item.trim().length > 0)
          .map((item) => `${field}: ${item.trim()}`);
      });
    if (collectedErrors.length > 0) return collectedErrors.join(" | ");
  }

  return undefined;
}

async function parseApiResponse<T>(response: Response): Promise<T> {
  const rawText = await response.text();

  if (!rawText) {
    if (response.ok) {
      return undefined as T;
    }

    throw new HttpError(GLOBAL_ERROR_MESSAGE, response.status);
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(rawText);
  } catch {
    if (response.ok) {
      return undefined as T;
    }

    const plainMessage = rawText.trim();
    throw new HttpError(plainMessage || GLOBAL_ERROR_MESSAGE, response.status);
  }

  if (isWrappedApiResponse<T>(parsed)) {
    const wrappedRecord = parsed as unknown as Record<string, unknown>;
    const wrappedSuccess = getCaseInsensitiveValue(wrappedRecord, "success");
    const wrappedMessage = getStringValueCaseInsensitive(wrappedRecord, "message");
    const isSuccess = typeof wrappedSuccess === "boolean" ? wrappedSuccess : false;
    if (!response.ok || !isSuccess) {
      throw new HttpError(wrappedMessage || GLOBAL_ERROR_MESSAGE, response.status);
    }

    return getCaseInsensitiveValue(wrappedRecord, "data") as T;
  }

  if (!response.ok) {
    const extracted = extractMessageFromUnknown(parsed);
    throw new HttpError(extracted || GLOBAL_ERROR_MESSAGE, response.status);
  }

  return parsed as T;
}

export async function getJson<TResponse>(path: string, accessToken?: string): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "GET",
    headers: buildHeaders(accessToken)
  });

  return parseApiResponse<TResponse>(response);
}

export async function postJson<TResponse, TPayload = unknown>(
  path: string,
  payload: TPayload,
  accessToken?: string
): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: buildHeaders(accessToken),
    body: JSON.stringify(payload)
  });

  return parseApiResponse<TResponse>(response);
}


export async function putJson<TResponse, TPayload = unknown>(
  path: string,
  payload: TPayload,
  accessToken?: string
): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "PUT",
    headers: buildHeaders(accessToken),
    body: JSON.stringify(payload)
  });

  return parseApiResponse<TResponse>(response);
}

export async function putForm<TResponse>(path: string, formData: FormData, accessToken?: string): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "PUT",
    headers: buildHeaders(accessToken, false),
    body: formData
  });

  return parseApiResponse<TResponse>(response);
}

export async function postForm<TResponse>(path: string, formData: FormData, accessToken?: string): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: buildHeaders(accessToken, false),
    body: formData
  });

  return parseApiResponse<TResponse>(response);
}

export async function deleteJson<TResponse>(path: string, accessToken?: string): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "DELETE",
    headers: buildHeaders(accessToken)
  });

  return parseApiResponse<TResponse>(response);
}
