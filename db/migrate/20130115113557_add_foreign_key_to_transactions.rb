class AddForeignKeyToTransactions < ActiveRecord::Migration

  def up
    execute <<-SQL
      ALTER TABLE transactions
        ADD CONSTRAINT fk__transactions__recurrence_id
        FOREIGN KEY (recurrence_id)
        REFERENCES recurrences (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE;
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE transactions DROP CONSTRAINT fk__transactions__recurrence_id;
    SQL
  end

end
