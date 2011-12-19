class CreateTlogBackgrounds < ActiveRecord::Migration
  def self.up
    create_table :tlog_backgrounds do |t|

      t.column :tlog_design_settings_id, :integer

      t.column "content_type", :string
      t.column "filename", :string
      t.column "size", :integer

      # used with thumbnails, always required
      t.column "parent_id",  :integer
      t.column "thumbnail", :string

      # required for images only
      t.column "width", :integer
      t.column "height", :integer

      # required for db-based files only
      t.column "db_file_id", :integer
    end

    add_index :tlog_backgrounds, [:tlog_design_settings_id]

    # only for db-based files
    # create_table :db_files, :force => true do |t|
    #      t.column :data, :binary
    # end
  end

  def self.down
    drop_table :tlog_backgrounds

    # only for db-based files
    # drop_table :db_files
  end
end
