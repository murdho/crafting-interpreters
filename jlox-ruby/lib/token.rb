class Token
  attr_reader :type
  attr_reader :lexeme
  attr_reader :literal
  attr_reader :line

  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  def to_s
    "#{type} #{lexeme} #{literal}"
  end
end
