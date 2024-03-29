module TransactionBase

  include TransactionsHelper

  TRANSACTION_TYPES = {
    "Upcoming" => "upcoming",
    "Pending"  => "pending",
    "Cleared"  => "cleared",
    "Posted"   => "posted"
  }

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

  module InstanceMethods

    def upcoming? ; transaction_type == "upcoming" ; end
    def cleared?  ; transaction_type == "cleared"  ; end

    def debit  ; format_money(-amount) if amount && amount < 0  ; end
    def credit ; format_money(amount)  if amount && amount >= 0 ; end

    def debit?  ; debit != nil  ; end
    def credit? ; credit != nil ; end

    def validate_money
      if self.amount.blank?
        self.errors.add(:debit, "must have a debit or a credit")
        self.errors.add(:credit, "must have a debit or a credit")
      elsif self.amount < -100_000_000
        errors[:debit] << "must be less than 1,000,000"
      elsif self.amount > 100_000_000
        errors[:credit] << "must be less than 1,000,000"
      end
    end

  end

  module ClassMethods

  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :validates, :amount, presence: true
    base.send :validates, :transaction_type, inclusion: { in: TRANSACTION_TYPES.values }
    base.send :validate, :validate_money
  end

end
