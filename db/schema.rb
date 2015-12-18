# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150114032214) do

  create_table "address_errors", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "addresses", :force => true do |t|
    t.integer  "encryption_pair_id"
    t.integer  "original_id"
    t.text     "code_name"
    t.integer  "user_id"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "address1"
    t.text     "address2"
    t.text     "apt"
    t.text     "zip"
    t.text     "city"
    t.text     "state"
    t.text     "country"
    t.text     "phone"
    t.boolean  "erroneous",          :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "bitcoin_payments", :force => true do |t|
    t.integer  "original_id"
    t.integer  "user_id"
    t.integer  "sale_id"
    t.integer  "value",                        :limit => 8
    t.string   "input_address"
    t.integer  "confirmations"
    t.string   "transaction_hash"
    t.string   "input_transaction_hash"
    t.string   "destination_address"
    t.string   "raw_callback"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "payin_detected"
    t.integer  "technical_bitcoin_payment_id"
  end

  add_index "bitcoin_payments", ["input_address"], :name => "index_bitcoin_payments_on_input_address"
  add_index "bitcoin_payments", ["sale_id"], :name => "index_bitcoin_payments_on_sale_id"
  add_index "bitcoin_payments", ["transaction_hash"], :name => "index_bitcoin_payments_on_transaction_hash", :unique => true

  create_table "checkout_wallets", :force => true do |t|
    t.integer  "sale_id"
    t.integer  "value_needed",                  :limit => 8
    t.string   "secret_authorization_token"
    t.string   "input_address"
    t.string   "transaction_hash"
    t.string   "input_transaction_hash"
    t.string   "destination_address"
    t.datetime "last_manual_lookup"
    t.datetime "last_successful_manual_lookup"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "cl_associations", :id => false, :force => true do |t|
    t.integer "coupon_id"
    t.integer "line_item_id"
  end

  add_index "cl_associations", ["coupon_id", "line_item_id"], :name => "index_cl_associations_on_coupon_id_and_line_item_id"

  create_table "costs_of_bitcoins", :force => true do |t|
    t.integer  "qty_of_satoshi", :limit => 8
    t.decimal  "cost_in_usd"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "coupons", :force => true do |t|
    t.integer  "discount_id"
    t.integer  "product_id"
    t.string   "applies_to"
    t.text     "token"
    t.integer  "usage_limit",      :default => 0
    t.boolean  "enabled",          :default => true
    t.string   "disabled_message"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "cs_associations", :id => false, :force => true do |t|
    t.integer "coupon_id"
    t.integer "sale_id"
  end

  add_index "cs_associations", ["coupon_id", "sale_id"], :name => "index_cs_associations_on_coupon_id_and_sale_id"

  create_table "discounts", :force => true do |t|
    t.integer  "original_id"
    t.string   "name"
    t.string   "discount_type"
    t.string   "applies_to"
    t.boolean  "active"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "encryption_pairs", :force => true do |t|
    t.integer  "original_id"
    t.text     "public_key"
    t.text     "private_key"
    t.string   "test_value"
    t.boolean  "tested"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "line_items", :force => true do |t|
    t.integer  "original_id"
    t.integer  "sale_id"
    t.integer  "discounted_item_id"
    t.string   "product_sku"
    t.integer  "qty"
    t.decimal  "price"
    t.integer  "shipping_cost_btc",             :default => 0
    t.decimal  "shipping_cost_usd",             :default => 0.0
    t.decimal  "shipping_cost",                 :default => 0.0
    t.decimal  "discounted_amount"
    t.string   "currency_used"
    t.decimal  "price_extend",                  :default => 0.0
    t.decimal  "price_after_product_discounts"
    t.text     "description"
    t.decimal  "discount"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "line_items", ["sale_id"], :name => "index_line_items_on_sale_id"

  create_table "messages", :force => true do |t|
    t.text     "header"
    t.text     "body"
    t.string   "message_type"
    t.string   "message_status", :default => "unread"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "pd_associations", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "discount_id"
  end

  add_index "pd_associations", ["product_id", "discount_id"], :name => "index_pd_associations_on_product_id_and_discount_id"

  create_table "pricing_rules", :force => true do |t|
    t.string   "case_value"
    t.string   "condition"
    t.string   "discount_percent"
    t.string   "shipping_modifier"
    t.integer  "discount_id"
    t.integer  "shipping_plan_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "products", :force => true do |t|
    t.integer  "original_id"
    t.integer  "shipping_plan_id"
    t.string   "name"
    t.string   "description"
    t.string   "material"
    t.string   "digital_copy"
    t.string   "thumbnail"
    t.string   "sku"
    t.string   "category"
    t.boolean  "is_discount"
    t.decimal  "price_usd"
    t.boolean  "taxable"
    t.decimal  "shipping_cost_usd"
    t.decimal  "qty_on_hand"
    t.decimal  "qty_ordered"
    t.decimal  "pounds"
    t.decimal  "length"
    t.decimal  "width"
    t.decimal  "height"
    t.boolean  "required_by_system"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "products", ["sku"], :name => "index_products_on_sku", :unique => true

  create_table "ready_for_shipment_batches", :force => true do |t|
    t.integer  "original_id"
    t.integer  "sale_id"
    t.string   "batch_stamp"
    t.string   "sf_integrity_hash"
    t.string   "acf_integrity_hash"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "ready_for_shipment_batches", ["batch_stamp"], :name => "index_ready_for_shipment_batches_on_batch_stamp", :unique => true

  create_table "retailers", :force => true do |t|
    t.integer  "address_id"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "fax"
    t.string   "map_link"
    t.text     "notes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sales", :force => true do |t|
    t.integer  "original_id"
    t.integer  "user_id"
    t.integer  "address_id"
    t.integer  "ready_for_shipment_batch_id"
    t.integer  "utilized_bitcoin_wallet_id"
    t.boolean  "prepped",                     :default => false
    t.datetime "shipped"
    t.datetime "receipt_confirmed"
    t.datetime "delivery_acknowledged"
    t.string   "currency_used",               :default => "BTC"
    t.decimal  "sale_amount"
    t.decimal  "shipping_amount"
    t.decimal  "total_amount"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "shipping_plans", :force => true do |t|
    t.integer  "product_id"
    t.string   "name"
    t.decimal  "shipping_base_amount"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "stories", :force => true do |t|
    t.string   "date"
    t.string   "header"
    t.text     "body"
    t.string   "img"
    t.string   "author"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "utilized_bitcoin_wallets", :force => true do |t|
    t.integer  "original_id"
    t.text     "wallet_address"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
