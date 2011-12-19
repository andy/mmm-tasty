class AddOptimizationIndexesToEntries < ActiveRecord::Migration
  def self.up
    # ускоряет запрос: SELECT * FROM entries WHERE (is_private = 0 AND is_mainpageable = 1) ORDER BY entries.id DESC LIMIT 0, 15
    #  вызывается с main/live
    add_index :entries, [:is_mainpageable, :is_private, :id]
  end

  def self.down
    remove_index :entries, [:is_mainpageable, :is_private, :id]
  end
end
