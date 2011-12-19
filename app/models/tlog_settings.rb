class TlogSettings < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id
  validates_inclusion_of :default_visibility, :in => %(public private mainpageable voteable), :on => :save

  def default_visibility
    read_attribute(:default_visibility) || 'mainpageable'
  end

  # обновляем счетчик последнего обновления, чтобы сбросить кеш для страниц.
  #  это актуально когда пользователь переключается между режимами "обычный" / "тлогодень"
  #  и когда он включает / выключает опцию "скрыть прошлое"
  after_save do |record|
    record.user.update_attributes(:entries_updated_at => Time.now) unless (record.changes.keys - ['updated_at']).blank?
  end
end