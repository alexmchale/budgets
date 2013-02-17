module AccountPollers

  class Base

    def import_from_ofx(ofx_content)
      # Parse the content.
      ofx = OfxParser::OfxParser.parse(ofx_content)
      bank_account = ofx.bank_account

      ## Read account-level data from the file.
      #if bank_account.statement.end_date >= Date.today
      #  @account.current_balance = bank_account.balance_in_pennies
      #end

      # Organize the transactions by date.
      dates = {}
      bank_account.statement.transactions.each do |t|
        dates[t.date.to_date] ||= []
        dates[t.date.to_date] << t
      end

      # Process the transactions.
      dates.keys.sort.reverse.each do |date|
        dates[date].each do |t1|
          # The dataset that we are importing is always considered to be the most
          # complete view of the day.
          amount = t1.amount_in_pennies

          # Count the number of transactions already recorded on the date of the
          # amount specified.
          cousins_in_db = @account.posted_transactions.where(:paid_at => date, :amount => amount).count

          # The "twins" calculation is used to ensure that we deal with seemingly
          # identical yet distinct entries.
          twins = dates[date].count do |t2|
            [ :memo, :payee, :amount, :check_number ].all? { |k| t1.send(k) == t2.send(k) }
          end

          # The "cousins" calculation counts the number of trivially identical
          # entries are in the current dataset.
          cousins = dates[date].count { |t2| t1.amount == t2.amount }

          # These are the fields we'll check to see if the record is already in
          # the database.
          fields = {
            :account          => @account,
            :paid_at          => date,
            :payee            => t1.memo != "" ? t1.memo.basic : t1.payee.basic,
            :description      => "",
            :amount           => amount,
            #:check_number    => t1.check_number,
            :transaction_type => "posted"
          }

          # Calculate the number of records we should create.
          number_to_create = [ [ twins, cousins - cousins_in_db ].min, 0 ].max

          # Raise an exception if the number of cousins don't mesh with the
          # current dataset being canonical.
          raise IncorrectTransactionCount if cousins_in_db > cousins

          number_to_create.times do
            @account.transactions.create! fields
          end
        end
      end
    end

    def node_cents(node)
      node.inner_text.to_cents
    end

    def find_first(node, *searches)
      searches.flatten.each do |search|
        result = node.search(search).first
        return result if result
      end
      return nil
    end

  end

  # Custom Errors

  class NoUsernameError < Exception; end
  class NoPasswordError < Exception; end
  class NoSecurityQuestionAnswerError < Exception; end
  class CannotFindBalance < Exception; end
  class CannotFindTransactions < Exception; end
  class CannotFindOfxFile < Exception; end
  class IncorrectTransactionCount < Exception; end
  class CheckImageNotFound < Exception; end

end
