module TransactionsHelper

  include ActionView::Helpers::NumberHelper

  def format_money(total_cents)
    dollars = total_cents.to_i / 100
    cents   = total_cents.to_i % 100

    formatted_dollars = number_with_delimiter(dollars)
    formatted_cents   = "%02d" % cents

    if total_cents < 0
      "(" + formatted_dollars + "." + formatted_cents + ")"
    else
      formatted_dollars + "." + formatted_cents
    end
  end

  def transaction_tr(transaction, options = {}, &block)
    data_fields = {
      id:         transaction.id,
      type:       transaction.transaction_type,
      frequency:  transaction.recurrence.try(:frequency),
      first:      if transaction.first? then "1" else "0" end,
      last:       if transaction.last?  then "1" else "0" end
    }.map do |k, v|
      %[data-#{h k}="#{h v}"]
    end.join(" ")

    klasses = [
      "transaction",
      transaction.paid_at.strftime("%B").downcase,
      cycle("even", "odd"),
      if options[:month_changed] then "month-changed" else "month-didnt-change" end
    ]

    raw <<-HTML
      <tr class="#{klasses.join ' '}" #{data_fields}>
        #{capture &block}
      </tr>
    HTML
  end

end
