class Event < ActiveRecord::Base
  belongs_to :current_user, :class_name => "User", :foreign_key => "current_user_id"
  belongs_to :current_site, :class_name => "User", :foreign_key => "current_site_id"

  validates_presence_of :message, :on => :create

  class << self
    def log(message)
      Event.create(:message => message, :current_site => current_site, :current_user => current_user, :remote_ip => request.remote_ip)
    end
  end
end
