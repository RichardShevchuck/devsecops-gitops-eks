# Architecture — Connections

## Services

| Service  | Container name  | Image/build        | Listens on | Published to host |
|----------|------------------|---------------------|------------|--------------------|
| frontend | frontend         | `./frontend`        | 5173       | `5173:5173`        |
| backend  | backend          | `./backend`         | 8080       | `31100:8080`       |
| mongodb  | mongo-service    | `mongo:latest`      | 27017      | `27017:27017`      |
| redis    | redis-service    | `redis:7.0.5-alpine`| 6379       | not published (internal only, `expose`) |

## Connection flow (local docker-compose)

```
Browser (host machine)
   │  http://localhost:5173
   ▼
frontend container  ──serves static JS/HTML only, no reverse proxy──

Browser (host machine)
   │  http://localhost:31100   (VITE_API_PATH, called directly from browser JS)
   ▼
backend container
   │  mongodb://mongo-service/wanderlust   (docker-network DNS name)
   │  redis://redis-service:6379            (docker-network DNS name)
   ▼
mongo-service / redis-service containers
```

## Rule of thumb

- **Container → container** (backend → mongo, backend → redis): use Docker Compose DNS name (`service` key or `container_name`), resolved by Docker's embedded DNS within the compose network. Never `localhost`/`127.0.0.1` here — that resolves to the calling container itself.
- **Host process or browser → container**: use `localhost`/`127.0.0.1` (or the host's real address for remote access) + the **published** host port. The browser never participates in the Docker network and cannot resolve container/service DNS names.
- This project's frontend has no dev-server proxy (`vite.config.ts` has no `server.proxy`) — the browser calls the backend directly via `VITE_API_PATH`, bypassing the frontend container entirely for API calls.

## Environment variables

### backend (`backend/.env.docker`)

| Var | Purpose | Read by |
|-----|---------|---------|
| `MONGODB_URI` | Mongo connection string | `config/db.js` |
| `REDIS_URL` | Redis connection string | `services/redis.js` |
| `PORT` | Express listen port | `server.js` |
| `JWT_SECRET` | Token signing secret — generate your own, never commit | auth controllers |
| `ACCESS_TOKEN_EXPIRES_IN` / `REFRESH_TOKEN_EXPIRES_IN` | Cookie/token TTL | auth controllers |
| `FRONTEND_URL` | **Unused** — not read anywhere in current code, safe to drop or wire up later for CORS whitelist | — |

### frontend (`frontend/.env.docker` — not committed, create locally)

| Var | Purpose |
|-----|---------|
| `VITE_API_PATH` | Base URL the browser uses to call the backend, e.g. `http://localhost:31100` |

## Next: Kubernetes

When this moves to `kubernetes/`, the same connections map to:

- `docker-compose ports:` → K8s `Service` (`ClusterIP` for internal, exposed via `Ingress`/`LoadBalancer` for browser-facing)
- `mongo-service`/`redis-service` DNS names → K8s Service DNS (`<service>.<namespace>.svc.cluster.local`)
- `.env.docker` files → `ConfigMap` (non-secret vars) + `Secret` (`JWT_SECRET`, connection strings with credentials)
- Container-to-container vs browser-to-container rule still applies — only now "published to host" becomes "exposed via Ingress"
