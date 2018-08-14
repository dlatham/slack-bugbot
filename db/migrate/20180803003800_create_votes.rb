class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.string :card_id
      t.integer :count

      t.timestamps
    end
  end
end
