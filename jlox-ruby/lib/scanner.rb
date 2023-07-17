require_relative "core_ext/bigdecimal"

require_relative "token"
require_relative "token_type"

class Scanner
  include TokenType

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until at_end?
      # We are at the beginning of the next lexeme.
      @start = current
      scan_token
    end

    tokens << Token.new(EOF, "", nil, line)
    tokens
  end

  private

  attr_reader :source
  attr_reader :tokens
  attr_reader :start
  attr_reader :current
  attr_reader :line

  KEYWORDS = {
    "and" => AND,
    "class" => CLASS,
    "else" => ELSE,
    "false" => TokenType::FALSE,
    "for" => FOR,
    "fun" => FUN,
    "if" => IF,
    "nil" => TokenType::NIL,
    "or" => OR,
    "print" => PRINT,
    "return" => RETURN,
    "super" => SUPER,
    "this" => THIS,
    "true" => TokenType::TRUE,
    "var" => VAR,
    "while" => WHILE
  }

  def scan_token
    c = advance

    case c
    when "(" then add_token(LEFT_PAREN)
    when ")" then add_token(RIGHT_PAREN)
    when "{" then add_token(LEFT_BRACE)
    when "}" then add_token(RIGHT_BRACE)
    when "," then add_token(COMMA)
    when "." then add_token(DOT)
    when "-" then add_token(MINUS)
    when "+" then add_token(PLUS)
    when ";" then add_token(SEMICOLON)
    when "*" then add_token(STAR)
    when "!" then add_token(match?("=") ? BANG_EQUAL : BANG)
    when "=" then add_token(match?("=") ? EQUAL_EQUAL : EQUAL)
    when "<" then add_token(match?("=") ? LESS_EQUAL : LESS)
    when ">" then add_token(match?("=") ? GREATER_EQUAL : GREATER)
    when "/"
      if match?("/")
        # A comment goes until the end of the line.
        advance while peek != "\n" && !at_end?
      else
        add_token(SLASH)
      end

    when " ", "\r", "\t"
      # Ignore whitespace.

    when "\n"
      @line += 1

    when '"' then string
    else
      if digit?(c)
        number
      elsif alpha?(c)
        identifier
      else
        Lox.error(line, "Unexpected character.")
      end
    end
  end

  def identifier
    advance while alpha_numeric?(peek)

    text = source[start...current]
    type = KEYWORDS[text] || IDENTIFIER
    add_token(type)
  end

  def number
    advance while digit?(peek)

    # Look for a fractional part.
    if peek == "." && digit?(peek_next)
      advance # Consume the ".".

      advance while digit?(peek)
    end

    add_token(NUMBER, source[start...current].to_d)
  end

  def string
    while peek != '"' && !at_end?
      @line += 1 if peek == "\n"
      advance
    end

    if at_end?
      Lox.error(line, "Unterminated string.")
      return
    end

    advance # The closing ".

    # Trim the surrounding quotes.
    value = source[(start + 1)...(current - 1)]
    add_token(STRING, value)
  end

  def match?(expected)
    return false if at_end?
    return false unless source[current] == expected

    @current += 1
    true
  end

  def peek
    return "\0" if at_end?
    source[current]
  end

  def peek_next
    return "\0" if current + 1 >= source.length
    source[current + 1]
  end

  def alpha?(c)
    (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_"
  end

  def alpha_numeric?(c)
    alpha?(c) || digit?(c)
  end

  def digit?(c)
    c >= "0" && c <= "9"
  end

  def at_end?
    current >= source.length
  end

  def advance
    source[current].tap { @current += 1 }
  end

  def add_token(token_type, literal = nil)
    text = source[start...current]
    tokens << Token.new(token_type, text, literal, line)
  end
end
