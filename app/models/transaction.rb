class Transaction < ActiveRecord::Base

  ### Modules ###

  include TransactionBase

  ### Constants ###

  ### Relations ###

  belongs_to :recurrence

  ### Scopes ###

  scope :upcoming, includes(:recurrence).where(transaction_type: "upcoming")
  scope :cleared, includes(:recurrence).where(transaction_type: "cleared")
  scope :posted, includes(:recurrence).where(transaction_type: "posted")
  scope :paid_asc, order("paid_at ASC")
  scope :paid_desc, order("paid_at DESC, amount ASC")
  scope :budget_through, -> date { where("paid_at < ? OR (paid_at <= ? AND amount < 0)", date, date) }

  ### Validations ###

  validates :paid_at, presence: true
  validates :recurrence_id, presence: true

  ### Callbacks ###

  ### Miscellaneous ###

  accepts_nested_attributes_for :recurrence

  ### Methods ###

  def first?
    self.recurrence.next_date(nil) == self.paid_at
  end

  def last?
    self.recurrence.next_date(self.paid_at) == nil
  end

end
