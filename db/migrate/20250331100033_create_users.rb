class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, null: false, index: {unique: true}
      t.string :microsoft_uid
      t.text :token
      t.text :refresh_token
      t.datetime :expires_at
      t.string :image

      t.timestamps
    end
  end
end
