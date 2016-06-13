class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :user, index: true, foreign_key: true
      t.string :tfl_card_id
      t.string :last_4_digits
      t.string :expiry
      t.string :network
      t.timestamps null: false
    end
  end
end
