class Account < ActiveRecord::Base

  include TransactionsHelper

  serialize :polling_parameters, JSON
  has_many :transactions
  belongs_to :user
  around_save :create_transaction_for_balance_change_hook, if: -> a { a.create_transaction_for_balance_change == "1" && a.posted_balance_changed? }

  attr_accessor :create_transaction_for_balance_change

  def posted_balance_string
    format_money posted_balance
  end

  def posted_balance_string=(balance)
    self.posted_balance =
      case balance
      when String
        (balance.gsub(/[^0-9.\-]/, "").to_f * 100).to_i
      when Float
        (balance * 100).to_i
      else
        balance.to_i
      end
  end

  def poll
    return if polling_parameters.blank?
    return if polling_parameters["type"].blank?

    polling_parameters["type"].constantize.new(self).poll
  end

  def cleared_transactions
    self.transactions.cleared
  end

  def pending_transactions
    self.transactions.pending
  end

  def posted_transactions
    self.transactions.posted
  end

  def security_answer(question, answer = nil)
    self.polling_parameters["security_answers"] ||= {}
    security_answers = self.polling_parameters["security_answers"]

    if answer
      security_answers[question] = answer
      self
    else
      security_answers.each do |k, v|
        return v if k == question
      end
      nil
    end
  end

  def options_for_time_window
    {
      "Next Two Weeks" => "2weeks",
      "This Month"     => "month",
      "This Year"      => "year",
      "Two Months"     => "2months",
      "Three Months"   => "3months",
      "Six Months"     => "6months",
      "Twelve Months"  => "12months"
    }
  end

  def upcoming_time_window
    $redis.get("account:#{self.id}:upcoming_time_window") || "month"
  end

  def upcoming_time_window=(time_window)
    time_window = "month" unless options_for_time_window.values.include?(time_window.to_s)
    $redis.set("account:#{self.id}:upcoming_time_window", time_window.to_s)
  end

  def upcoming_time_window_end
    case upcoming_time_window
    when "2weeks"   then 14.days.from_now.to_date
    when "month"    then Date.today.end_of_month
    when "year"     then Date.today.end_of_year
    when "2months"  then Date.today.next_month.end_of_month
    when "3months"  then Date.today.next_month.next_month.end_of_month
    when "6months"  then Date.today.next_month.next_month.next_month.next_month.next_month.end_of_month
    when "12months" then Date.today.next_month.next_month.next_month.next_month.next_month.next_month.next_month.next_month.next_month.next_month.next_month.end_of_month
    end
  end

  def create_transaction_for_balance_change_hook
    t =
      Transaction.new \
        account:          self,
        paid_at:          Time.now,
        amount:           posted_balance_was - posted_balance,
        payee:            "Balance Adjustment",
        description:      "",
        transaction_type: "posted"

    transaction do
      t.save! if yield
    end
  end

end
