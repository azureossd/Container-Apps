"""
Simple MCP Tool Server — Service Health Checker
=================================================
A lightweight MCP-compatible HTTP server that exposes two tools:
  1. http_health_check  — Probe a URL and return status code, latency, headers
  2. batch_health_check — Check multiple URLs at once and return a summary table

Runs as a Streamable HTTP MCP server on port 8080 (configurable).

Requirements:
    pip install mcp[cli] httpx uvicorn

Usage:
    python server.py                       # start on 0.0.0.0:8080
    MCP_PORT=9090 python server.py         # override port
"""

from __future__ import annotations

import os
import time
import asyncio
import secrets
from typing import Any

import httpx
from mcp.server.fastmcp import FastMCP

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

# ---------------------------------------------------------------------------
# API key configuration
# ---------------------------------------------------------------------------
# Set via environment variable. If not set, a random key is generated and
# printed to stdout on startup (useful for first-time setup).
API_KEY = os.environ.get("MCP_API_KEY")

if not API_KEY:
    API_KEY = secrets.token_urlsafe(48)
    print(f"WARNING: No MCP_API_KEY set. Generated ephemeral key:\n   {API_KEY}")
    print("   Set MCP_API_KEY env var for a persistent key.\n")


class ApiKeyMiddleware(BaseHTTPMiddleware):
    """Validates Bearer token on every request except the root health probe."""

    async def dispatch(self, request: Request, call_next):
        # Allow unauthenticated health probe at root (for Container Apps liveness)
        if request.url.path == "/" and request.method == "GET":
            return await call_next(request)

        auth_header = request.headers.get("authorization", "")
        if not auth_header.startswith("Bearer "):
            return JSONResponse({"error": "Missing Bearer token"}, status_code=401)

        token = auth_header[len("Bearer "):]
        if not secrets.compare_digest(token, API_KEY):
            return JSONResponse({"error": "Invalid API key"}, status_code=403)

        return await call_next(request)

# ---------------------------------------------------------------------------
# MCP server instance
# ---------------------------------------------------------------------------
mcp = FastMCP(
    "health-check-mcp", host="0.0.0.0", port="8080",
    instructions=(
        "Provides HTTP health-check tools. Use http_health_check to probe "
        "a single endpoint, or batch_health_check for multiple endpoints."
    ),
)


# ---------------------------------------------------------------------------
# Tool 1 — Single endpoint health check
# ---------------------------------------------------------------------------
@mcp.tool()
async def http_health_check(
    url: str,
    method: str = "GET",
    timeout_seconds: int = 10,
    expected_status: int = 200,
) -> dict[str, Any]:
    """
    Probe a single HTTP(S) endpoint and return health information.

    Args:
        url: The full URL to check (e.g. https://example.com/health).
        method: HTTP method to use (GET, HEAD, POST). Defaults to GET.
        timeout_seconds: Request timeout in seconds. Defaults to 10.
        expected_status: The HTTP status code that indicates "healthy". Defaults to 200.

    Returns:
        A dict with: url, status_code, latency_ms, healthy (bool),
        content_length, server_header, and any error message.
    """
    result: dict[str, Any] = {
        "url": url,
        "method": method,
        "status_code": None,
        "latency_ms": None,
        "healthy": False,
        "content_length": None,
        "server_header": None,
        "error": None,
        "custom_flag": None,
    }

    try:
        async with httpx.AsyncClient(
            follow_redirects=True, timeout=timeout_seconds
        ) as client:
            start = time.perf_counter()
            response = await client.request(method.upper(), url)
            elapsed_ms = round((time.perf_counter() - start) * 1000, 2)

            result["status_code"] = response.status_code
            result["latency_ms"] = elapsed_ms
            result["healthy"] = response.status_code == expected_status
            result["content_length"] = response.headers.get("content-length")
            result["server_header"] = response.headers.get("server")
            result["custom_flag"] = "returned by the custom health check MCP server tool"

    except httpx.TimeoutException:
        result["error"] = f"Request timed out after {timeout_seconds}s"
    except httpx.ConnectError as exc:
        result["error"] = f"Connection failed: {exc}"
    except Exception as exc:  # noqa: BLE001
        result["error"] = f"Unexpected error: {exc}"

    return result


# ---------------------------------------------------------------------------
# Tool 2 — Batch health check for multiple endpoints
# ---------------------------------------------------------------------------
@mcp.tool()
async def batch_health_check(
    urls: list[str],
    timeout_seconds: int = 10,
    expected_status: int = 200,
) -> dict[str, Any]:
    """
    Check multiple HTTP(S) endpoints concurrently and return a summary.

    Args:
        urls: List of URLs to check.
        timeout_seconds: Per-request timeout in seconds. Defaults to 10.
        expected_status: The HTTP status code that means "healthy". Defaults to 200.

    Returns:
        A dict with: total, healthy_count, unhealthy_count, and a results list.
    """
    tasks = [
        http_health_check(
            url=u,
            method="GET",
            timeout_seconds=timeout_seconds,
            expected_status=expected_status,
        )
        for u in urls
    ]
    results = await asyncio.gather(*tasks)

    healthy = sum(1 for r in results if r["healthy"])
    return {
        "total": len(results),
        "healthy_count": healthy,
        "unhealthy_count": len(results) - healthy,
        "results": list(results),
    }


# ---------------------------------------------------------------------------
# Entrypoint — Streamable HTTP transport
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    port = int(os.environ.get("MCP_PORT", "8080"))
    print(f"Starting health-check-mcp server on 0.0.0.0:{port}")
    mcp.run(transport="streamable-http",)
