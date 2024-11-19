class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :document_number, null: false
      t.string :phone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.date :birthdate, null: false
      t.decimal :income, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :customers, :document_number, unique: true
  end
end
