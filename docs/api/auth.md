---
name: Authentication API
description: Authentication endpoints including login, refresh, logout and user information
display: true
tags: ["api", "authentication", "security", "jwt"]
image: null
last_modified: 04.01.2026
created: 03.01.2026
---

# Auth API

## Endpoints
- POST /v1/auth/login
- POST /v1/auth/refresh
- POST /v1/auth/logout
- GET /v1/auth/me

## Example: login
```bash
curl -X POST https://api.example.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"correct horse"}'
```
Response
```json
{
  "access_token": "<jwt>",
  "refresh_token": "<jwt>",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

## Claims
- `sub`: user id
- `tenant`: tenant id
- `exp`: unix expiry
- `roles`: array of role keys

## Error map
| Code | Meaning | Action |
| --- | --- | --- |
| 400 | invalid payload | fix JSON |
| 401 | bad credentials | reset password |
| 429 | throttled | back off |
| 500 | server error | retry with jitter |

## Related
- [Threat model](../security/threat-model.md)
- [On-call runbook](../runbooks/oncall.md)
