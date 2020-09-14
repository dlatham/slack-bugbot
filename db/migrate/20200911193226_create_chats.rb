class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.string :dpid
      t.string :session
      t.string :provider
      t.string :data

      t.timestamps
    end
  end
end
