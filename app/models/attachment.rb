class Attachment < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user

  has_attachment :storage => :file_system, :max_size => 7.megabytes, :resize_to => '800x4000>', :thumbnails => { :thumb => '200x1500>', :tlog => '420x4000>' }, :file_system_path => 'public/uc/att'
  validates_as_attachment

  serialize :metadata, Hash

  validates_presence_of :entry_id
  validates_presence_of :user_id

  before_create do |att|
    begin
      # находим соответсвующий обработчик для закаченного файла
      require 'mime/types'

      type = MIME::Types.type_for(att.full_filename)[0].media_type.capitalize + 'Attachment'
      att[:type] = type if %w( AudioAttachment ImageAttachment ).include?(type)
    rescue
    end
  end


  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(RAILS_ROOT, file_system_path, tasty_attachment_path(filename), "#{id}_#{user_id}_#{entry_id}_" + thumbnail_name_for(thumbnail))
  end

  def tasty_attachment_path(filename)
    File.join(Digest::SHA1.hexdigest(filename)[0..1], Digest::SHA1.hexdigest(filename)[2..3])
  end
end

class AudioAttachment < Attachment
  # достает ArtWork картинку которая утсанавливается в iTunes
  def artwork
    Mp3Info.open(self.full_filename) do |mp3|
      (mp3.tag2.PIC || mp3.tag2.APIC).unpack('Z*xa*')[1] rescue nil
    end
  rescue
    nil
  end

  protected
    def load_metadata
      mp3 = Mp3Info.open self.full_filename
      self.metadata = { :title => mp3.tag.title || mp3.tag2.TIT1 || mp3.tag2.TIT2 || '',
                    :album => mp3.tag.album || mp3.tag2.TALB || '',
                    :artist => mp3.tag.artist || mp3.tag2.TPE1 || mp3.tag2.TPE2 || ''
                  }
    end
end

class ImageAttachment < Attachment
end
