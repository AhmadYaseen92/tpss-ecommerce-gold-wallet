import type { ApiResponse } from "../types/apiTypes";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:5095";

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

async function parseApiResponse<T>(response: Response): Promise<T> {
  const rawText = await response.text();

  if (!rawText) {
    if (response.ok) {
      return undefined as T;
    }

    throw new HttpError(`API request failed with status ${response.status}`, response.status);
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(rawText);
  } catch {
    if (response.ok) {
      return undefined as T;
    }

    throw new HttpError("Received invalid JSON response from API", response.status);
  }

  if (isWrappedApiResponse<T>(parsed)) {
    if (!response.ok || !parsed.success) {
      throw new HttpError(parsed.message || "API request failed", response.status);
    }

    return parsed.data as T;
  }

  if (!response.ok) {
    throw new HttpError(`API request failed with status ${response.status}`, response.status);
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
