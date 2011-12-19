class AddSidebar < ActiveRecord::Migration
  def self.up
    create_table :sidebar_sections do |t|
      t.column :user_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :position, :integer
      t.column :is_open, :boolean, :null => false, :default => false
    end

    add_index :sidebar_sections, [:user_id, :position]

    create_table :sidebar_elements do |t|
      t.column :sidebar_section_id, :integer, :null => false
      t.column :type, :string, :limit => 25, :null => false
      t.column :content, :text, :null => false
      t.column :position, :integer
    end
  end

  def self.down
    drop_table :sidebar_elements
    drop_table :sidebar_sections
  end
end
