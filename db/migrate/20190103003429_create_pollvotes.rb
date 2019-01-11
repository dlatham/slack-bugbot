class CreatePollvotes < ActiveRecord::Migration[5.2]
  def change
    create_table :pollvotes do |t|
      t.references :poll, foreign_key: true
      t.string :username
      t.integer :question_id

      t.timestamps
    end
  end
end
