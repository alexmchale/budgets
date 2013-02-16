class UpdateNotNullStatusOfTransactionRecurrence < ActiveRecord::Migration

  def up
    execute <<-SQL
      ALTER TABLE transactions ALTER COLUMN recurrence_id DROP NOT NULL;

      ALTER TABLE transactions ADD CONSTRAINT chk_recurrence_id CHECK (
        (transaction_type IN ('cleared','upcoming') AND recurrence_id IS NOT NULL)
        OR
        (transaction_type NOT IN ('cleared','upcoming') AND recurrence_id IS NULL)
      );
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE transactions DROP CONSTRAINT chk_recurrence_id;
    SQL
  end

end
