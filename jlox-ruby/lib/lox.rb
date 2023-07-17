require_relative "scanner"

module Lox
  extend self

  def run_file(path)
    run(File.read(path))
    exit 65 if @had_error
  end

  def run_prompt
    loop do
      print "> "
      line = gets
      break if line.nil?
      run(line)
      @had_error = false
    end
  end

  def run(source)
    tokens = Scanner.new(source).scan_tokens
    tokens.each { puts _1 }
  end

  def error(line, message)
    report(line, "", message)
  end

  def report(line, where, message)
    puts "[line #{line}] Error #{where}: #{message}"
    @had_error = true
  end
end
