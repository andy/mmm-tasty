class CreateSphinxCounter < ActiveRecord::Migration
  def self.up
    create_table :sphinx_counter, :id => false do |t|
      t.column :counter_id, :integer
      t.column :max_doc_id, :integer
    end

    add_index :sphinx_counter, [:counter_id], :unique => true
  end

  def self.down
    drop_table :sphinx_counter
  end
end
