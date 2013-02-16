module TransactionableController

  module InstanceMethods

    def cast_params
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

      # Query parameters.

      @final_date = Date.parse(params[:end_date]) if params[:end_date].present?
      @final_date ||= Date.today.next_month.beginning_of_month
    end

    def load_upcoming_transactions
      @upcoming_transactions = Transaction.upcoming.paid_desc.budget_through(@final_date).to_a
      @upcoming_transactions.reverse.inject(current_account.posted_balance) do |balance, transaction|
        transaction.balance = balance + transaction.amount
      end
    end

    def load_cleared_transactions
      @cleared_transactions = Transaction.cleared.paid_desc.to_a
    end

    def load_posted_transactions
      @posted_transactions = Transaction.pending.paid_desc.to_a + Transaction.posted.paid_desc.to_a

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
