output "redis_cache_id" {
  value       = azurerm_redis_cache.redis.id
  description = "The ID of the Redis Cache"
}

# Output the Redis hostname
output "redis_hostname" {
  value = azurerm_redis_cache.redis.hostname
}

# Output the Redis Primary Access Key
output "redis_primary_access_key" {
  value = azurerm_redis_cache.redis.primary_access_key
}
