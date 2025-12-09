# Troubleshooting

Common issues and solutions.

## Database Issues

{%- if values.database != "none" %}
### Connection Refused

```
PG::ConnectionBad: could not connect to server
```

**Solutions:**
1. Check database is running: `pg_isready -h localhost`
2. Verify credentials in `.env`
3. Check `DATABASE_HOST` and `DATABASE_PORT`

### Migration Pending

```
ActiveRecord::PendingMigrationError
```

**Solution:**
```bash
rails db:migrate
```
{%- endif %}

{%- if values.cache == "elasticache-redis" or values.jobProcessor == "sidekiq" %}
## Redis Issues

### Connection Refused

```
Redis::CannotConnectError
```

**Solutions:**
1. Check Redis is running: `redis-cli ping`
2. Verify `REDIS_URL` in `.env`
{%- endif %}

{%- if values.jobProcessor == "sidekiq" %}
## Sidekiq Issues

### Jobs Not Processing

**Solutions:**
1. Ensure Sidekiq is running: `bundle exec sidekiq`
2. Check Redis connection
3. Verify queue names in job classes
{%- endif %}

## API Issues

### 500 Internal Server Error

**Solutions:**
1. Check `log/development.log` for stack trace
2. Verify environment variables
3. Check database connection

### CORS Errors

**Solutions:**
1. Check `CORS_ORIGINS` includes your frontend domain
2. Verify `config/initializers/cors.rb`

## Performance Issues

### Slow Requests

**Solutions:**
1. Check Grafana/Tempo for slow queries
2. Add database indexes
3. Implement caching

### High Memory Usage

**Solutions:**
1. Check for N+1 queries
2. Use pagination for large collections
3. Review background job memory usage

## Deployment Issues

### Container Won't Start

**Solutions:**
1. Check Docker logs: `docker logs <container>`
2. Verify environment variables
3. Check health endpoint works

### Health Check Failing

**Solutions:**
1. Ensure `/health` endpoint is accessible
2. Check database/Redis connections
3. Verify all services are healthy

## Getting Help

- Check Rails logs: `log/development.log`
- Check Grafana Tempo traces
- Slack: #platform-help
