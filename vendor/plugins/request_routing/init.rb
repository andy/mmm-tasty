if ActionController::Routing.const_defined? 'RouteBuilder'
  # Use new style.
  require 'request_routing'
else
  # Use old style
  require 'request_routing_old'
end