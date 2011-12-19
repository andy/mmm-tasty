class TlogDesignSettings < ActiveRecord::Base
  belongs_to :user
  has_one :tlog_background, :dependent => :destroy

  # validates_format_of :theme, :with => /^[a-z0-9\_-]+$/i, :if => Proc.new { |t| !t.theme.blank? }
end
