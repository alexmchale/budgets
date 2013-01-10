class Transaction < ActiveRecord::Base

  TRANSACTION_TYPES = {
    "Upcoming" => "upcoming",
    "Pending"  => "pending",
    "Cleared"  => "cleared"
  }

end
