if defined?(Rack::Timeout)
  Rack::Timeout.timeout = (ENV["RACK_TIMEOUT"] || 25).to_i
end
