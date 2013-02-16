module AccountPollers

  class CommerceBank

    def initialize(account)
      @account = account
      @username = @account.polling_parameters["username"]
      @password = @account.polling_parameters["password"]
      @agent = Mechanize.new
    end

    def poll
      return if @username.blank? || @password.blank?

      sign_in
      read_current_balance
      read_pending_transactions
      read_history

      @account.save!

      self
    end

    private

    # HTTP Process

    def sign_in
      page                      = @agent.get("https://banking.commercebank.com/CBI/login.aspx")
      form                      = page.form("MAINFORM")
      form["txtUserID"]         = @username
      form["TestJavaScript"]    = "GOODCOOKIE"
      form["btnValidateSignon"] = "Continue >"
      page                      = @agent.submit(form, form.buttons.first)
      form                      = page.form("MAINFORM")
      question                  = find_security_question(page)

      raise NoSecurityQuestionAnswerError.new(question) unless answer = @account.security_answer(question)

      form["txtChallengeAnswer"]   = answer
      page                         = @agent.submit(form, form.buttons.first)
      form                         = page.form("MAINFORM")
      form["txtPassword"]          = @password
      form["saveComputer"]         = "rdoBindDeviceNo"
      form["ddlSignonDestination"] = "Accounts.Activity"
      form["TestJavaScript"]       = "GOODCOOKIE"
      @activity_page               = @agent.submit(form, form.buttons.first)
    end

    def read_current_balance
      @account.posted_balance = node_cents(@activity_page.search("//a[text()='Available Balance:']/../../td[3]"))

      raise CannotFindBalance unless @account.posted_balance

      #@account.current_balance = node_cents(@activity_page.search("//a[text()='Current Balance:']/../../td[3]"))
      #@account.available_balance = node_cents(@activity_page.search("//a[text()='Available Balance:']/../../td[3]"))
      #
      #raise CannotFindBalance unless @account.current_balance && @account.available_balance
    end

    def read_pending_transactions
      pending_transactions_panel = @activity_page.search("div#PendingTransactionsControl_pnlMemoPostContainer")
      raw_items = pending_transactions_panel.search("tr.rgRow, tr.rgAltRow")

      @account.pending_transactions.destroy_all

      raw_items.map do |raw_item|
        Transaction.new.tap do |t|
          debit = find_first(raw_item, "td[3]/span/a", "td[3]/span", "td[3]").inner_text.to_cents
          credit = find_first(raw_item, "td[4]/span/a", "td[4]/span", "td[4]").inner_text.to_cents

          t.id               = nil
          t.account          = @account
          t.paid_at          = Date.strptime(find_first(raw_item, "td[1]").inner_text.basic, "%m/%d/%Y")
          t.payee            = find_first(raw_item, "td[2]/span/a", "td[2]/span", "td[2]").inner_text.basic
          t.description      = "";
          t.amount           = -debit if debit.to_i > 0
          t.amount           = credit if credit.to_i > 0
          t.transaction_type = "pending"
          t.save!
        end
      end
    end

    def read_history
      from_date = (Date.today - 60).strftime("%Y-%m-%d")
      to_date = Date.today.strftime("%Y-%m-%d")
      ofx_file = @agent.get("https://banking.commercebank.com/CBI/Accounts/CBI/Download.ashx?Index=1&From=#{from_date}&To=#{to_date}&Type=ofx&DurationOfMonths=6")

      raise CannotFindOfxFile unless ofx_file.kind_of?(Mechanize::File)

      import_from_ofx ofx_file.body
    end

    # Utilities

    def find_security_question(page)
      page.
        search('span#challengeQuestion').
        inner_text.
        gsub(UTF8_NONBREAKING_SPACE, " ").
        strip
    end

    def inject_activity_date_fields(form, first, last)
      first_dashes = first.strftime("%Y-%m-%d")
      first_slashes = first.strftime("%m/%d/%Y")
      first_commas = first.strftime("%Y,%m,%d")
      last_dashes = last.strftime("%Y-%m-%d")
      last_slashes = last.strftime("%m/%d/%Y")
      last_commas = last.strftime("%Y,%m,%d")
      form["PostedTransactionsControl$rdpFilterFromDate"] = first_dashes
      form["PostedTransactionsControl_rdpFilterFromDate_dateInput_text"] = first_slashes
      form["PostedTransactionsControl$rdpFilterFromDate$dateInput"] = %|#{first_dashes}-00-00-00|
      form["PostedTransactionsControl_rdpFilterFromDate_dateInput_ClientState"] = %|{"enabled":true,"emptyMessage":"","minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
      form["PostedTransactionsControl_rdpFilterFromDate_calendar_SD"] = %|[[#{first_commas}]]|
      form["PostedTransactionsControl_rdpFilterFromDate_calendar_AD"] = %|[[1980,1,1],[#{last_commas}],[#{last_commas}]]|
      form["PostedTransactionsControl_rdpFilterFromDate_ClientState"] = %|{"minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
      form["PostedTransactionsControl$rdpFilterToDate"] = last_dashes
      form["PostedTransactionsControl_rdpFilterToDate_dateInput_text"] = last_slashes
      form["PostedTransactionsControl$rdpFilterToDate$dateInput"] = %|#{last_dashes}-00-00-00|
      form["PostedTransactionsControl_rdpFilterToDate_dateInput_ClientState"] = %|{"enabled":true,"emptyMessage":"","minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
      form["PostedTransactionsControl_rdpFilterToDate_calendar_SD"] = %|[]|
      form["PostedTransactionsControl_rdpFilterToDate_calendar_AD"] = %|[[1980,1,1],[#{last_commas}],[#{last_commas}]]|
      form["PostedTransactionsControl_rdpFilterToDate_ClientState"] = %|{"minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
    end

    def inject_downloads_date_fields(form, first, last)
      first_dashes = first.strftime("%Y-%m-%d")
      first_slashes = first.strftime("%m/%d/%Y")
      first_commas = first.strftime("%Y,%m,%d")
      last_dashes = last.strftime("%Y-%m-%d")
      last_slashes = last.strftime("%m/%d/%Y")
      last_commas = last.strftime("%Y,%m,%d")
      form["txtFromDate"] = first_dashes
      form["txtFromDate_dateInput_text"] = first_slashes
      form["txtFromDate$dateInput"] = %|#{first_dashes}-00-00-00|
      form["txtFromDate_dateInput_ClientState"] = %|{"enabled":true,"emptyMessage":"","minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
      form["txtFromDate_calendar_SD"] = %|[[#{first_commas}]]|
      form["txtFromDate_calendar_AD"] = %|[[1980,1,1],[#{last_commas}],[#{last_commas}]]|
      form["txtFromDate_ClientState"] = %|{"minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
      form["txtToDate"] = last_dashes
      form["txtToDate_dateInput_text"] = last_slashes
      form["txtToDate$dateInput"] = %|#{last_dashes}-00-00-00|
      form["txtToDate_dateInput_ClientState"] = %|{"enabled":true,"emptyMessage":"","minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
      form["txtToDate_calendar_SD"] = %|[]|
      form["txtToDate_calendar_AD"] = %|[[1980,1,1],[#{last_commas}],[#{last_commas}]]|
      form["txtToDate_ClientState"] = %|{"minDateStr":"1/1/1980 0:0:0","maxDateStr":"#{last_slashes} 0:0:0"}|
    end

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

    UTF8_NONBREAKING_SPACE = "\xc2\xa0".force_encoding("UTF-8")

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
