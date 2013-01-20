class Recurrence < ActiveRecord::Base

  include TransactionBase

  validates :frequency, inclusion: { in: FREQUENCIES.values }
  validates :payee, presence: true
  validates :starts_at, presence: true

  belongs_to :account
  has_many :transactions

  after_create :create_transactions

  def create_transactions through = 1.year.from_now.to_date
    existing_dates = self.transactions.select(:paid_at).to_a.map(&:paid_at)
    date = self.next_date nil

    while date && date <= through && (!ends_at || date <= ends_at)
      if !existing_dates.include?(date)
        Transaction.create! \
          account_id:       self.account_id,
          recurrence_id:    self.id,
          paid_at:          date,
          amount:           self.amount,
          transaction_type: self.transaction_type,
          payee:            self.payee,
          description:      self.description

        existing_dates << date
      end

      date = self.next_date date
    end
  end

  def next_date previous_date
    return self.starts_at if previous_date == nil

    next_date =
      case self.frequency
      when "once"
        nil
      when "daily"
        previous_date + 1
      when "weekly"
        previous_date + 7
      when "biweekly"
        previous_date + 14
      when "1n15"
        previous_date.mday < 15 ? previous_date + (15-previous_date.mday) : previous_date.next_month.beginning_of_month
      when "monthly"
        previous_date.next_month
      when "quarterly"
        previous_date.next_month.next_month.next_month
      when "semiannually"
        (1..6).inject(previous_date) { |date| date.next_month }
      when "annually"
        (1..12).inject(previous_date) { |date| date.next_month }
      else
        raise "unknown frequency #{frequency}"
      end

    return if ! next_date
    return next_date if ! ends_at
    return next_date if next_date <= ends_at
  end

end
