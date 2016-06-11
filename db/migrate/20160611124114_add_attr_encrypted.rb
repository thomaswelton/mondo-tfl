class AddAttrEncrypted < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_tfl_username, :string
    add_column :users, :encrypted_tfl_username_iv, :string
    add_column :users, :encrypted_tfl_password, :string
    add_column :users, :encrypted_tfl_password_iv, :string
  end
end
