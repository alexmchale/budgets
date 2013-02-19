$redis_client = Redis.new
$redis = Redis::Namespace.new("com.anticlever.budgets", redis: $redis_client)
