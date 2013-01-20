class AddDatabaseIntegrityToTransAndRecur < ActiveRecord::Migration

  def up
    execute <<-SQL
      ALTER TABLE recurrences ALTER COLUMN account_id SET NOT NULL;
      ALTER TABLE recurrences ALTER COLUMN frequency SET NOT NULL;
      ALTER TABLE recurrences ALTER COLUMN starts_at SET NOT NULL;
      ALTER TABLE recurrences ALTER COLUMN amount SET NOT NULL;
      ALTER TABLE recurrences ALTER COLUMN payee SET NOT NULL;
      ALTER TABLE recurrences ALTER COLUMN description SET NOT NULL;
      ALTER TABLE recurrences ALTER COLUMN transaction_type SET NOT NULL;

      ALTER TABLE recurrences ADD CONSTRAINT fk__recurrences__account_id FOREIGN KEY (account_id) REFERENCES accounts (id);
      ALTER TABLE recurrences ADD CONSTRAINT chk__recurrences__frequency CHECK (frequency IN ('once','daily','weekly','biweekly','1n15','monthly','quarterly','semiannually','annually'));
      ALTER TABLE recurrences ADD CONSTRAINT chk__recurrences__transaction_type CHECK (transaction_type IN ('upcoming','pending','cleared','posted'));

      ALTER TABLE transactions ALTER COLUMN amount SET NOT NULL;
      ALTER TABLE transactions ALTER COLUMN payee SET NOT NULL;
      ALTER TABLE transactions ALTER COLUMN description SET NOT NULL;
      ALTER TABLE transactions ALTER COLUMN paid_at SET NOT NULL;
      ALTER TABLE transactions ALTER COLUMN transaction_type SET NOT NULL;
      ALTER TABLE transactions ALTER COLUMN account_id SET NOT NULL;
      ALTER TABLE transactions ALTER COLUMN recurrence_id SET NOT NULL;

      ALTER TABLE transactions ADD CONSTRAINT fk__recurrences__account_id FOREIGN KEY (account_id) REFERENCES accounts (id);
      ALTER TABLE transactions ADD CONSTRAINT chk__recurrences__transaction_type CHECK (transaction_type IN ('upcoming','pending','cleared','posted'));
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE recurrences DROP CONSTRAINT fk__recurrences__account_id;
      ALTER TABLE recurrences DROP CONSTRAINT chk__recurrences__frequency;
      ALTER TABLE recurrences DROP CONSTRAINT chk__recurrences__transaction_type;
      ALTER TABLE transactions DROP CONSTRAINT fk__recurrences__account_id;
      ALTER TABLE transactions DROP CONSTRAINT chk__recurrences__transaction_type;
    SQL
  end

end
