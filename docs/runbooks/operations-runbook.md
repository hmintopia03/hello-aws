# Hello AWS Operations Runbook

## Purpose

This runbook documents how to diagnose and recover common production-like failures in the Hello AWS project.

## System Overview

Client
→ HTTPS
→ Nginx
→ FastAPI
→ PostgreSQL
→ Docker Compose
→ EC2
→ CloudWatch

## Incident Types

1. 502 Bad Gateway
2. API container down
3. Nginx config broken
4. Docker Compose not running
5. Disk full
6. TLS certificate issue
7. Deployment failed
8. CloudWatch alarm triggered


# Incident 01 - 502 Bad Gateway

## Symptom

The website loads, but API requests fail with:

502 Bad Gateway

## First Checks

```bash
curl -I https://hyemincho.dev
curl -I https://hyemincho.dev/api/health
```
## Check Nginx
```bash
sudo nginx -t
sudo systemctl status nginx
sudo journalctl -u nginx --no-pager -n 100
```
## Check Docker
```bash
docker ps
docker compose ps
docker logs <api-container-name> --tail 100
```
## Check Ports
```bash
ss -tulpn
```
## Likely Causes

- API container is down
- Nginx upstream points to the wrong port
- Docker network issue
- App crashed during startup
- Health endpoint failing

## Recovery
```bash
docker compose up -d --build
sudo nginx -t
sudo systemctl reload nginx
```
## Prevention

- Add health checks
- Log API startup failures
- Validate Nginx config before reload
- Keep deployment rollback steps documented

