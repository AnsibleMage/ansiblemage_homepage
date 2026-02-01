class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.string :excerpt
      t.boolean :published, default: false, null: false
      t.integer :likes_count, default: 0, null: false

      t.timestamps
    end
    add_index :posts, :slug, unique: true
  end
end
