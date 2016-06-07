class CreateJourneys < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.references :user, index: true, foreign_key: true
      t.string :from
      t.string :to
      t.date :date
      t.string :time
      t.integer :fare
      t.string :mondo_transaction_id
      t.timestamps null: false
    end
  end
end
