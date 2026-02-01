class CreateLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :likes do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :ip_address, null: false

      t.timestamps
    end

    add_index :likes, [:post_id, :user_id], unique: true, where: "user_id IS NOT NULL", name: "index_likes_on_post_and_user"
    add_index :likes, [:post_id, :ip_address], unique: true, where: "user_id IS NULL", name: "index_likes_on_post_and_ip_anonymous"
  end
end
