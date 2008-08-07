class TlogSettings < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :user_id
  validates_inclusion_of :default_visibility, :in => %(public private mainpageable voteable), :on => :save
  
  def default_visibility
    read_attribute(:default_visibility) || 'mainpageable'
  end
end