# Provides the ability to have session cookies for your Rails app calculated
# relative to the current time.
#
# In your environment.rb file (or in the environments/*.rb file of your choice),
# do something like the following:
#
#   CGI::Session.expire_after 1.month
#
# Session cookies will then expire one month after the session was created. This
# differs from the usual session cookie behavior in that the expiration date is
# not a fixed time, but rather relative to the current time.

class CGI
  class Session
    @@session_expiration_offset = 0
    
    def self.session_expiration_offset
      @@session_expiration_offset
    end
    
    def self.session_expiration_offset=(value)
      @@session_expiration_offset = value
    end

    def self.expire_after(value)
      @@session_expiration_offset = value
    end
    
    alias :initialize_without_dynamic_session_expiration :initialize #:nodoc:
    def initialize(request, option={}) #:nodoc:
      if @@session_expiration_offset && @@session_expiration_offset > 0
        option['session_expires'] = Time.now + @@session_expiration_offset
      end
      initialize_without_dynamic_session_expiration(request, option)
    end
    
  end
end