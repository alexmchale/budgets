class Account < ActiveRecord::Base

  serialize :polling_parameters, JSON
  has_many :transactions

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

end
