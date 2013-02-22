class Account < ActiveRecord::Base

  serialize :polling_parameters, JSON
  has_many :transactions
  composed_of :stated_balance, :class_name => 'Money', :mapping => %w(stated_balance amount), :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }
  composed_of :posted_balance, :class_name => 'Money', :mapping => %w(posted_balance amount), :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

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

end
