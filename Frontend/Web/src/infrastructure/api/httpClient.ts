import type { ApiResponse } from "../apiTypes";

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

async function parseApiResponse<T>(response: Response): Promise<T> {
  const json = (await response.json()) as ApiResponse<T>;
  if (!response.ok || !json.success) {
    throw new HttpError(json.message || "API request failed", response.status);
  }

  return json.data as T;
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
