class String
  def compact
    gsub(/\n/, ' ').gsub(/ +/, ' ').strip
  end

  def camelize
    split("_").each {|s| s.capitalize! }.join("")
  end
end

