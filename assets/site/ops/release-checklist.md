# Release Checklist

## Pre-flight
- [ ] Changelog updated
- [ ] Tests green (unit, integration, e2e)
- [ ] Feature flags ready
- [ ] DB migrations reviewed and reversible

## Deploy
- [ ] Tag created (semver)
- [ ] Artifacts signed and uploaded
- [ ] Deploy to staging and soak 30 min
- [ ] Promote to prod via blue/green

## Post-flight
- [ ] Verify dashboards (latency, error rate)
- [ ] Run smoke tests
- [ ] Announce in #releases
- [ ] Create rollback plan link

## Rollback
```bash
# example helm rollback
helm rollback api 42 --namespace prod
```

## Links
- [On-call runbook](../runbooks/oncall.md)
- [Threat model](../security/threat-model.md)
