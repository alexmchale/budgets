class CreateUsers < ActiveRecord::Migration

  def change

    create_table :users do |t|
      t.string :email
      t.string :password_hash

      t.timestamps
    end

    add_column :accounts, :user_id, :integer

  end

end
