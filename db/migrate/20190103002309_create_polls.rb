class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.string :pollname
      t.boolean :active
      t.boolean :open_submit
      t.datetime :expires
      t.json :questions

      t.timestamps
    end
  end
end
