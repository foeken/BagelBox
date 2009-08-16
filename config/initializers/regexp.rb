class << Regexp
  def unescape(re)
    if re.is_a?(String)
      input = re
    else
      input = re.source
    end
    input.sub(/\A\\A/, '').sub(/\\z\z/, '').gsub(/\\(.)/, '\1')
  end
end