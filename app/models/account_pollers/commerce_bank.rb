module AccountPollers

  class CommerceBank < Base

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
      node = @activity_page.search(%{//*[@id="pageBodyHeader"]/table/tr/td[1]/div[2]/div[2]/table/tr/td[3]/table/tr[2]/td[3]})
      @account.posted_balance = node_cents(node)
      #p @activity_page.search("//table.summaryTable/tr[2]")
      #p @activity_page.search("//table.summaryTable/tr[2]/td[3]")
      #p node_cents(@activity_page.search("//table.summaryTable/tr[2]/td[3]"))
      #p @activity_page.search("//a[text()='Available Balance:']")
      #p @activity_page.search("//a[text()='Available Balance:']/..")
      #p @activity_page.search("//a[text()='Available Balance:']/../..")
      #p @activity_page.search("//a[text()='Available Balance:']/../../td[3]")

      #@account.posted_balance = node_cents(@activity_page.search("//a[text()='Available Balance:']/../../td[3]"))

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
      page.search('span#challengeQuestion').inner_text.basic
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

  end

end
