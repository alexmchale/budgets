class CreateRecurrences < ActiveRecord::Migration

  def change
    create_table :recurrences do |t|
      t.references :account
      t.string :frequency
      t.date :starts_at
      t.date :ends_at

      t.timestamps
    end

    add_index :recurrences, :account_id

    change_column :transactions, :paid_at, :date
  end

end
