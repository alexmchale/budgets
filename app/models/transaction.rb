class Transaction < ActiveRecord::Base

  include TransactionsHelper

  TRANSACTION_TYPES = {
    "Upcoming" => "upcoming",
    "Pending"  => "pending",
    "Cleared"  => "cleared",
    "Posted"   => "posted"
  }

  belongs_to :recurrence

  accepts_nested_attributes_for :recurrence

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :paid_at
  validates_inclusion_of :transaction_type, in: TRANSACTION_TYPES.values
  validate :validate_money

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

  protected

  def validate_money
    if self.amount.blank?
      self.errors.add(:debit, "must have a debit or a credit")
      self.errors.add(:credit, "must have a debit or a credit")
    end
  end

end
