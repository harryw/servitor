module QuotedArgs
  def quote(arg)
    escaped = arg.
        gsub("\\", {"\\" => "\\\\"}).
        gsub('"', {'"' => '\"'}).
        gsub('`', {'`' => '\`'})
    "\"#{escaped}\""
  end
end
