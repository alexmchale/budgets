class AddDefaultsToBalances < ActiveRecord::Migration

  def up
    execute <<-SQL
      UPDATE accounts SET posted_balance = 0 WHERE posted_balance IS NULL;
      UPDATE accounts SET stated_balance = 0 WHERE posted_balance IS NULL;
      ALTER TABLE accounts ALTER COLUMN posted_balance SET NOT NULL;
      ALTER TABLE accounts ALTER COLUMN posted_balance SET DEFAULT 0;
      ALTER TABLE accounts ALTER COLUMN stated_balance SET NOT NULL;
      ALTER TABLE accounts ALTER COLUMN stated_balance SET DEFAULT 0;
    SQL
  end

  def down
    execute <<-SQL
    SQL
  end

end
