require_relative 'parser/parser'
require_relative 'runtime/interpreter'
require_relative 'runtime/environment'

def main
  env = Environment.new

  debugging = ARGV[0] == '-debug'

  file = debugging ? ARGV[1] : ARGV[0]

  if file
    debugging = ARGV[1] == '-debug'
  end

  parser = Parser.new(debugging)
  interpreter = Interpreter.new
  input = ''

  if !file.nil?
    begin
      program = parser.produce_ast(File.read(file))
      puts program.to_s if debugging

      result = interpreter.evaluate(program, env)

      program.display_info if debugging
      puts result.to_s
    rescue CustomError => e
      if e.file.nil?
        e.set_file(file)
      end
      bt = ["#{e.file}:#{e.line_nr}: in '#{e.function}': #{e.message} (#{e.class})"]
      puts e.set_backtrace(bt)
    end
  else
    while (input = $stdin.gets.chomp) != 'exit'
      program = parser.produce_ast(input)
      puts program.to_s if debugging

      result = interpreter.evaluate(program, env)

      program.display_info if debugging
      puts result.to_s
    end
    puts 'Bye!'
  end
end

def custom_stack_trace(exception)
  trace = exception.backtrace.reject do |line|
    line.start_with?(RbConfig::CONFIG['rubylibdir']) ||
      line.include?('custom_error.rb')
  end

  trace.each_with_index do |line, index|
    puts "#{index + 1}: #{line}"
  end
end

main if __FILE__ == $PROGRAM_NAME
