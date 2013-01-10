class Transaction < ActiveRecord::Base
  attr_accessible :amount, :description, :paid_at, :payee, :transaction_type
end
