class Object

  def to_cents
    case self
    when Fixnum then self
    when Float then (self * 100).ceil.to_i
    when String
      case gsub(/[^0-9\.]/, "")
      when /(\d+)\.(\d\d)/
        dollars = $1.to_i
        cents = $2.to_i
        (if self =~ /-/ then -1 else 1 end) * (dollars * 100 + cents)
      when /(\d+)/
        dollars = $1.to_i
        cents = 0
        (if self =~ /-/ then -1 else 1 end) * (dollars * 100 + cents)
      end
    end
  end

  def format_money
    total = self.to_cents
    dollars = (total.abs / 100).to_s.reverse.split(/(:?...)/).find_all { |s| s.length > 0 }.join(",").reverse
    cents = "%02d" % (total.abs % 100)
    value = "#{dollars}.#{cents}"

    if total.to_i < 0
      "(#{value})"
    else
      "#{value}"
    end
  end

end
