class Transaction < ActiveRecord::Base

  include TransactionsHelper

  TRANSACTION_TYPES = {
    "Upcoming" => "upcoming",
    "Pending"  => "pending",
    "Cleared"  => "cleared",
    "Posted"   => "posted"
  }

  FREQUENCIES = {
    "Once"          => "once",
    "Every 2 Weeks" => "biweekly",
    "Monthly"       => "monthly"
  }

  belongs_to :recurrence

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :paid_at
  validates_inclusion_of :transaction_type, in: TRANSACTION_TYPES.values

  scope :upcoming, where(transaction_type: "upcoming")
  scope :cleared, where(transaction_type: "cleared")
  scope :posted, where(transaction_type: "posted")
  scope :paid_asc, order("paid_at ASC")
  scope :paid_desc, order("paid_at DESC")

  attr_accessor :balance, :frequency, :repeat_count, :debit, :credit

  def upcoming? ; transaction_type == "upcoming" ; end
  def cleared?  ; transaction_type == "cleared"  ; end

  def debit  ; format_money(-amount) if amount && amount < 0  ; end
  def credit ; format_money(amount)  if amount && amount >= 0 ; end

end
