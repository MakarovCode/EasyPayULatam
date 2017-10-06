# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171002155007) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "payu_payments", force: :cascade do |t|
    t.string   "start_date"
    t.string   "end_date"
    t.string   "period"
    t.string   "reference_code"
    t.string   "description"
    t.float    "amount"
    t.float    "tax"
    t.float    "tax_return_base"
    t.string   "currency"
    t.string   "buyer_full_name"
    t.string   "buyer_email"
    t.string   "shipping_address"
    t.string   "shipping_city"
    t.string   "shipping_country"
    t.string   "buyer_phone"
    t.integer  "transaction_state"
    t.float    "risk"
    t.string   "reference_pol"
    t.integer  "installments_units"
    t.datetime "processing_date"
    t.string   "cus"
    t.string   "pse_bank"
    t.string   "response_code"
    t.string   "payment_method"
    t.string   "payment_method_type"
    t.string   "payment_method_name"
    t.string   "payment_request_state"
    t.string   "franchise"
    t.string   "lap_transaction_state"
    t.string   "message"
    t.string   "authorization_code"
    t.string   "transaction_id"
    t.string   "trazability_code"
    t.string   "state_pol"
    t.string   "number_card"
    t.string   "payer_name"
    t.string   "billing_country"
    t.string   "response_message_pol"
    t.string   "sign"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "buyer_nickname"
    t.string   "bank_id"
    t.string   "customer_number"
    t.float    "administrative_fee_base"
    t.integer  "attempts"
    t.string   "merchant_id"
    t.string   "exchange_rate"
    t.string   "ip"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
