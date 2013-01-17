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

ActiveRecord::Schema.define(:version => 20130115113557) do

  create_table "accounts", :force => true do |t|
    t.integer  "stated_balance"
    t.integer  "posted_balance"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "recurrences", :force => true do |t|
    t.integer  "account_id"
    t.string   "frequency"
    t.date     "starts_at"
    t.date     "ends_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "amount"
    t.string   "payee"
    t.string   "description"
    t.string   "transaction_type"
  end

  add_index "recurrences", ["account_id"], :name => "index_recurrences_on_account_id"

  create_table "transactions", :force => true do |t|
    t.integer  "amount"
    t.string   "payee"
    t.string   "description"
    t.date     "paid_at"
    t.string   "transaction_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "account_id"
    t.integer  "balance"
    t.integer  "recurrence_id"
  end

end
