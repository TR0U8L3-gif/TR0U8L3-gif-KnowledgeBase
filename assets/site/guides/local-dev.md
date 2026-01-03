# Local Development Guide

## Prereqs
- macOS 13+
- Docker Desktop
- Flutter 3.24+
- Dart 3.4+
- Node 20+ (for docs site)

## Setup
```bash
# bootstrap
make bootstrap

# start services (postgres, redis, kafka)
docker compose up -d db cache kafka

# run backend
cd services/api && make dev

# run web client
cd web && npm install && npm run dev
```

## Environment
Create `.env.local` in repo root:
```
API_BASE_URL=http://localhost:8080
AUTH_SECRET=dev-secret
POSTGRES_URL=postgres://app:app@localhost:5432/app
REDIS_URL=redis://localhost:6379
KAFKA_BROKERS=localhost:9092
```

## Testing
- Unit: `make test`
- Lint: `make lint`
- Integration: `make test-integration`

## Troubleshooting
- Ports busy? `lsof -i :8080` then kill.
- DB schema drift? `make db-reset`.
- Flutter not finding CocoaPods? `sudo gem install cocoapods` then `pod install` under `ios/`.

## References
- [Architecture overview](../architecture/overview.md)
- [Incident template](../ops/incident-template.md)
