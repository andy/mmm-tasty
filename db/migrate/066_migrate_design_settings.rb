class MigrateDesignSettings < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      TlogDesignSettings.transaction do
        @design = user.tlog_design_settings || TlogDesignSettings.new(:user => user)
        @design.update_attributes!({ :theme => user.tlog_settings.theme, :user_css => user.tlog_settings.design })

        TlogSettings.increment_counter('css_revision', user.tlog_settings.id)
      end
    end
    remove_column :tlog_settings, :theme
    remove_column :tlog_settings, :design
  end

  def self.down
    raise IrreversibleMigration
  end
end
