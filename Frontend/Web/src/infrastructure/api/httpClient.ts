import type { ApiResponse } from "../apiTypes";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://localhost:5294";

export class HttpError extends Error {
  constructor(message: string, public readonly statusCode?: number) {
    super(message);
  }
}

export async function postJson<TResponse, TPayload = unknown>(
  path: string,
  payload: TPayload,
  accessToken?: string
): Promise<TResponse> {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {})
    },
    body: JSON.stringify(payload)
  });

  const json = (await response.json()) as ApiResponse<TResponse>;

  if (!response.ok || !json.success || !json.data) {
    throw new HttpError(json.message || "API request failed", response.status);
  }

  return json.data;
}
