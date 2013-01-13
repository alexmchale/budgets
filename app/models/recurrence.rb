class Recurrence < ActiveRecord::Base

  belongs_to :account
  has_many :transactions

  attr_accessible :ends_at, :frequency, :starts_at

end
