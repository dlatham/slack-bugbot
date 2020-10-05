class AddMessageToChat < ActiveRecord::Migration[5.2]
  def change
  	add_column :chats, :message, :string
  end
end
