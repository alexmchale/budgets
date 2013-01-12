class Transaction < ActiveRecord::Base

  TRANSACTION_TYPES = {
    "Upcoming" => "upcoming",
    "Pending"  => "pending",
    "Cleared"  => "cleared",
    "Posted"   => "posted"
  }

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :paid_at
  validates_inclusion_of :transaction_type, in: TRANSACTION_TYPES.values

  scope :upcoming, where(transaction_type: "upcoming")
  scope :cleared, where(transaction_type: "cleared")
  scope :posted, where(transaction_type: "posted")
  scope :paid_asc, order("paid_at ASC")
  scope :paid_desc, order("paid_at DESC")

  def upcoming? ; transaction_type == "upcoming" ; end
  def cleared?  ; transaction_type == "cleared"  ; end

end
