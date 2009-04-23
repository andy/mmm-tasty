#
# Disposable email validations
#
# http://undisposable.org
#
require 'net/http'
require 'uri'
require 'json'

module Disposable
  def is_disposable_email?(email)
    req = Net::HTTP::Get.new("/services/json/isDisposableEmail/?email=#{email}")
    res = Net::HTTP.start('www.undisposable.net') { |http| http.request(req) }

    if res.is_a?(Net::HTTPOK)
      json = JSON.parse(res.body)
      return true if json['stat'] == 'ok' && json['email']['isdisposable'] == true
    end

    false
  end

  module_function :is_disposable_email?
end