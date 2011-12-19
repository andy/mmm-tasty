class SidebarSection < ActiveRecord::Base
  belongs_to :user
  has_many :elements, :class_name => 'SidebarElement', :order => :position, :dependent => :destroy

  validates_presence_of :name
  validates_associated :user
end