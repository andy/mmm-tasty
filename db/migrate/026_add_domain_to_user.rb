class AddDomainToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :domain, :string, :null => true, :unique => true
    add_index :users, :domain
  end

  def self.down
    remove_column :users, :domain
  end
end
