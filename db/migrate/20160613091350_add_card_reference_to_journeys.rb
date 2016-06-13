class AddCardReferenceToJourneys < ActiveRecord::Migration
  def change
    add_reference :journeys, :card
  end
end
