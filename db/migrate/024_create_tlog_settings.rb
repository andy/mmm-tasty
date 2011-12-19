class CreateTlogSettings < ActiveRecord::Migration
  def self.up
    create_table :tlog_settings do |t|
      t.column :user_id, :integer, :null => false
      t.column :title, :string
      t.column :design, :text
      t.column :about, :text
      t.column :updated_at, :timestamp
    end

    # переносим данные из одной таблицы в другую
    User.find(:all).each do |user|
      next unless user.settings
      if TlogSettings.create :user => user, :title => user.settings[:title], :about => user.settings[:about]
        user.settings.delete(:title)
        user.settings.delete(:about)
        user.update_attribute(:settings, user.settings)
      end
    end
  end

  def self.down
    # we would really loose way too much if we migrate it backwards
    raise IrreversibleMigration
  end
end
