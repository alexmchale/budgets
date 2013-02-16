class AddPollingParametersToAccounts < ActiveRecord::Migration

  def change
    add_column :accounts, :polling_parameters, :text
  end

end
