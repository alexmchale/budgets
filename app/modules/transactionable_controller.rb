module TransactionableController

  module InstanceMethods

    def cast_params
      # Define a proc to parse dates.

      cast_date = Proc.new do |hash, field|
        if hash.present? && hash[field].present?
          date = Chronic.parse(hash[field]).try(:to_date)
          date ||= Date.parse(hash[field])
          hash[field] = date if date
        end
      end

      # Cast Transaction parameters.

      [ params[:transaction], params[:recurrence] ].each do |hash|
        if hash.present?
          if hash[:debit].present?
            hash[:amount] = "-#{hash[:debit]}"
          end

          if hash[:credit].present?
            hash[:amount] = hash[:credit]
          end

          if hash[:amount].present?
            hash[:amount].gsub! /[^0-9\.\-]/, ""
            hash[:amount] = (hash[:amount].to_f * 100).to_i
          end

          cast_date.call hash, :paid_at
          cast_date.call hash, :starts_at
          cast_date.call hash, :ends_at

          hash.delete :debit
          hash.delete :credit
        end
      end
    end

    def load_upcoming_transactions
      balance = current_account.posted_balance || current_account.stated_balance || 0

      @upcoming_transactions = current_account.transactions.upcoming.paid_desc.budget_through(current_account.upcoming_time_window_end).to_a

      @upcoming_transactions.reverse.inject(balance) do |balance, transaction|
        transaction.balance = balance + transaction.amount
      end
    end

    def load_cleared_transactions
      @cleared_transactions = current_account.transactions.cleared.paid_desc.to_a
    end

    def load_posted_transactions
      @posted_transactions  = current_account.transactions.pending.paid_desc.to_a
      @posted_transactions += current_account.transactions.posted.paid_desc.to_a

      @posted_transactions.sort! do |t1, t2|
        t2.paid_at <=> t1.paid_at
      end

      balance = current_account.posted_balance

      @posted_transactions.each do |transaction|
        transaction.balance = balance
        balance -= transaction.amount
      end
    end

    def load_dynamic_transactions
      load_upcoming_transactions
      load_cleared_transactions
      load_posted_transactions
    end

  end

  module ClassMethods

  end

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :before_filter, :cast_params
  end

end
