require_relative 'parser/parser'
require_relative 'runtime/interpreter'
require_relative 'runtime/enviroment'

def main
  env = Enviroment.new

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

main if __FILE__ == $PROGRAM_NAME
