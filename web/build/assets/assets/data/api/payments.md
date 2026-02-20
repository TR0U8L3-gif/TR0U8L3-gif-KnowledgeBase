---
name: Payments API
description: Payment processing endpoints including intent creation, confirmation and webhooks
display: true
tags: ["api", "payments", "billing", "webhooks"]
image: null
last_modified: 04.01.2026
created: 03.01.2026
---

# Payments API

## Endpoints
- POST /v1/payments/intent
- POST /v1/payments/confirm
- GET /v1/payments/{id}

## Sequence
```mermaid
sequenceDiagram
  participant C as Client
  participant B as Billing
  participant P as PSP
  C->>B: POST /payments/intent
  B->>P: Create payment intent
  P-->>B: Intent id + client secret
  B-->>C: Return intent
  C->>P: Confirm with client secret
  P-->>B: Webhook payment.succeeded
  B->>B: Mark invoice paid
```

## Request/response
```http
POST /v1/payments/intent
Content-Type: application/json

{ "amount": 2599, "currency": "USD", "customer_id": "cus_123" }
```
Response
```json
{ "id": "pay_abc", "client_secret": "sek_test", "status": "requires_confirmation" }
```

## Webhooks
- `payment.succeeded`
- `payment.failed`
- `payment.refunded`

Verify with HMAC header `X-Signature` using shared secret per-tenant.

## SLAs
| Metric | Target |
| --- | --- |
| p95 intent create | < 400ms |
| p95 confirm | < 600ms |
| webhook delivery | < 5s |

## Notes
- Idempotency keys required on intent create
- PCI scope avoided via hosted fields
- Retries: exponential backoff (100ms base, 5 tries)
