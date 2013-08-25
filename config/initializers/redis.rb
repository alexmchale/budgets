$redis_client =
  if ENV["REDISTOGO_URL"].present?
    uri = URI.parse(ENV["REDISTOGO_URL"])
    Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    Redis.new(:host => "db")
  end

$redis = Redis::Namespace.new("com.anticlever.budgets", redis: $redis_client)
