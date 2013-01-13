class CreateAccounts < ActiveRecord::Migration

  def change
    create_table :accounts do |t|
      t.integer :stated_balance
      t.integer :posted_balance
      t.timestamps
    end

    change_table :transactions do |t|
      t.integer :account_id
      t.integer :balance
    end
  end

end
