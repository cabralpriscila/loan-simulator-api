# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_11_19_142349) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "document_number", null: false
    t.string "phone"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.date "birthdate", null: false
    t.decimal "income", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_customers_on_deleted_at"
    t.index ["document_number"], name: "index_customers_on_document_number", unique: true
  end

  create_table "loan_simulators", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.decimal "requested_amount", precision: 10, scale: 2, null: false
    t.integer "term_in_months", null: false
    t.decimal "interest_rate", precision: 5, scale: 2
    t.decimal "monthly_payment", precision: 10, scale: 2
    t.decimal "total_payment", precision: 10, scale: 2
    t.decimal "total_interest", precision: 10, scale: 2
    t.string "status", default: "pending"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_loan_simulators_on_customer_id"
    t.index ["deleted_at"], name: "index_loan_simulators_on_deleted_at"
  end

  add_foreign_key "loan_simulators", "customers"
end
