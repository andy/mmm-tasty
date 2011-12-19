class TlogBackground < ActiveRecord::Base
  belongs_to :tlog_design_settings

  has_attachment :storage => :file_system, :max_size => 4.megabytes, :content_type => :image, :file_system_path => 'public/uc/backgrounds'
  validates_as_attachment

  validates_presence_of :tlog_design_settings_id

  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(RAILS_ROOT, file_system_path, tasty_background_path(filename), "#{id}_#{tlog_design_settings.user_id}_" + thumbnail_name_for(thumbnail))
  end

  def tasty_background_path(filename)
    File.join(Digest::SHA1.hexdigest(filename)[0..1], Digest::SHA1.hexdigest(filename)[2..3])
  end
end
