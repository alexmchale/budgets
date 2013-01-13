class Recurrence < ActiveRecord::Base

  FREQUENCIES = {
    "Once"          => "once",
    "Daily"         => "daily",
    "Weekly"        => "weekly",
    "Every 2 Weeks" => "biweekly",
    "1st and 15th"  => "1n15",
    "Monthly"       => "monthly",
    "Quarterly"     => "quarterly",
    "Semi-Annually" => "semiannually",
    "Annually"      => "annually"
  }

  belongs_to :account
  has_many :transactions

end
