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
    program = parser.produce_ast(File.read(file))
    puts program.to_s if debugging

    result = interpreter.evaluate(program, env)

    program.display_info if debugging
    puts result.to_s
  else
    puts "Type 'exit' to quit"
    print ">> "
    while (input = $stdin.gets.chomp) != 'exit'
      program = parser.produce_ast(input)
      puts program.to_s if debugging
      program.display_info if debugging

      result = interpreter.evaluate(program, env)

      puts result.to_s
      print ">> "
    end
    puts 'Bye!'
  end
end

main if __FILE__ == $PROGRAM_NAME
