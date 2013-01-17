class AddOtherTransactionFieldsToRecurrences < ActiveRecord::Migration

  def change
    change_table :recurrences do |t|
      t.integer :amount
      t.string  :payee
      t.string  :description
      t.string  :transaction_type
    end
  end

end
