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
  return typeof value === "object" && value !== null && "success" in value;
}

function extractMessageFromUnknown(value: unknown): string | undefined {
  if (!value || typeof value !== "object") return undefined;

  const asRecord = value as Record<string, unknown>;

  if (typeof asRecord.message === "string" && asRecord.message.trim()) return asRecord.message.trim();
  if (typeof asRecord.title === "string" && asRecord.title.trim()) return asRecord.title.trim();
  if (typeof asRecord.detail === "string" && asRecord.detail.trim()) return asRecord.detail.trim();

  if (Array.isArray(asRecord.errors) && asRecord.errors.length > 0) {
    const firstError = asRecord.errors.find((item) => typeof item === "string" && item.trim());
    if (typeof firstError === "string") return firstError.trim();
  }

  if (asRecord.errors && typeof asRecord.errors === "object") {
    const firstErrorsEntry = Object.values(asRecord.errors as Record<string, unknown>).find((entry) => Array.isArray(entry));
    if (Array.isArray(firstErrorsEntry)) {
      const firstError = firstErrorsEntry.find((item) => typeof item === "string" && item.trim());
      if (typeof firstError === "string") return firstError.trim();
    }
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
    if (!response.ok || !parsed.success) {
      throw new HttpError(parsed.message || GLOBAL_ERROR_MESSAGE, response.status);
    }

    return parsed.data as T;
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
