class CreateLoanSimulators < ActiveRecord::Migration[8.0]
  def change
    create_table :loan_simulators do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :requested_amount, precision: 10, scale: 2, null: false
      t.integer :term_in_months, null: false
      t.decimal :interest_rate, precision: 5, scale: 2
      t.decimal :monthly_payment, precision: 10, scale: 2
      t.decimal :total_payment, precision: 10, scale: 2
      t.decimal :total_interest, precision: 10, scale: 2
      t.string :status, default: 'pending'
      t.datetime :deleted_at, index: true
      
      t.timestamps
    end
  end
end
