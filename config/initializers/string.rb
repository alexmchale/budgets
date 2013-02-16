class String

  UTF8_NONBREAKING_SPACE = "\xc2\xa0".force_encoding("UTF-8")

  def basic
    self.
      gsub(UTF8_NONBREAKING_SPACE, " ").
      gsub(/[\r\n]+/, " ").
      gsub(/\s+/, " ").
      strip
  end

end
