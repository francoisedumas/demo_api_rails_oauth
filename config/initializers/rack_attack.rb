class Rack::Attack
  # Throttle all requests by IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Throttle API requests specifically
  throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Throttle login attempts
  throttle('login/ip', limit: 5, period: 20.minutes) do |req|
    if req.path == '/api/v1/oauth/token' && req.post?
      req.ip
    end
  end
end
