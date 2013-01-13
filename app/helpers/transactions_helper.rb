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

end
