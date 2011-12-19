class EncryptPasswords < ActiveRecord::Migration
  def self.up
    add_column :users, :salt,             :string, :limit => 40
    add_column :users, :crypted_password, :string, :limit => 40

    User.find(:all).each do |user|
      unless user[:password].blank?
        user.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.url}--")
        user.crypted_password = User.encrypt(user[:password], user.salt)
        user[:password] = nil
        user.save(false)
      end
    end

    remove_column :users, :password
  end

  def self.down
    raise IrreversibleMigration
  end
end
