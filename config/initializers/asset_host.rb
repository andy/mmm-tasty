# map properly for developer-environment
ActionController::Base.asset_host = Proc.new do |source, request|
  if request.port == 80
    'http://www.mmm-tasty.ru'
  else
    "http://www.mmm-tasty.ru:#{request.port}"
  end
end