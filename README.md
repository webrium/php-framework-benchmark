# PHP Framework Benchmark — Laravel vs Webrium

## Project Structure

```
benchmark/
├── docker-compose.yml
├── database.sql
├── docker/
│   ├── Dockerfile.laravel
│   ├── Dockerfile.webrium
│   ├── nginx-laravel.conf
│   ├── nginx-webrium.conf
│   ├── entrypoint-laravel.sh
│   └── entrypoint-webrium.sh
├── laravel-app/
└── webrium-app/
```

---

## Step 1 — Database setup

```bash
mysql -u root -p < database.sql
```

Or inside MySQL client:

```sql
SOURCE /path/to/benchmark/database.sql;
```

---

## Step 2 — Configure database credentials

Edit `docker-compose.yml`:

```yaml
environment:
  DB_HOST: "host.docker.internal"
  DB_PORT: "3306"
  DB_DATABASE: "benchmark"
  DB_USERNAME: "root"
  DB_PASSWORD: ""
```

---

## Step 3 — Build and run

```bash
cd benchmark
docker compose up -d --build
```

---

## Step 4 — Check logs

```bash
docker compose logs -f
docker compose logs -f laravel
docker compose logs -f webrium
```

---

## URLs

| Framework | URL                   |
|-----------|-----------------------|
| Webrium   | http://localhost:8001 |
| Laravel   | http://localhost:8002 |

---

## Shell access

```bash
docker exec -it benchmark-laravel bash
docker exec -it benchmark-webrium bash
```

---

## Stop

```bash
docker compose down
```

---

## Notes

- `laravel-app/` and `webrium-app/` are mounted as volumes. Changes are reflected immediately inside the containers.
- If using a non-root MySQL user, grant access first:

```sql
GRANT ALL PRIVILEGES ON benchmark.* TO 'your_user'@'%';
FLUSH PRIVILEGES;
```

- If MySQL on Linux has `bind-address = 127.0.0.1` in `my.cnf`, change it to `0.0.0.0` and restart MySQL so Docker can connect.
