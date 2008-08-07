class AddIsDisabledToSocialAds < ActiveRecord::Migration
  def self.up
    add_column :social_ads, :is_disabled, :boolean, { :null => false, :default => false }
  end

  def self.down
    remove_column :social_ads, :is_disabled
  end
end
