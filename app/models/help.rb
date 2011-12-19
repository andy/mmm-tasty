class Help < ActiveRecord::Base
  attr_accessible :body, :path

  validates_presence_of :path, :on => :create, :message => "can't be blank"
  validates_presence_of :body, :on => :create, :message => "can't be blank"
end
