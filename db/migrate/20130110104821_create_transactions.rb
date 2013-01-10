class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :amount
      t.string :payee
      t.string :description
      t.datetime :paid_at
      t.string :transaction_type

      t.timestamps
    end
  end
end
