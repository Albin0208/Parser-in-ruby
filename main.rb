require_relative 'parser/parser'
require_relative 'runtime/interpreter'
require_relative 'runtime/environment'

#
# The entrypoint in to the language
#
def main
  debugging = ARGV[0] == '-debug'
  
  file = debugging ? ARGV[1] : ARGV[0]
  
  if file
    debugging = ARGV[1] == '-debug'
  end
  
  env = Runtime::Environment.new
  env.setup_native_functions()
  parser = Parser.new(debugging)
  interpreter = Runtime::Interpreter.new
  input = ''

  if !file.nil?
    begin
      raise "Error: File is required to have a extension of .cobra" unless File.extname(file) == '.cobra'
      program = parser.produce_ast(File.read(file))
      puts program.to_s if debugging
      program.display_info if debugging

      interpreter.evaluate(program, env)
    rescue => e
      if debugging
        raise e
      else
        error_message = "#{e.message}"
        # error_message += "Call stack:\n"
        # # @call_stack.reverse_each do |stack_frame|
        # #   node = stack_frame[:node]
        # #   line_number = stack_frame[:line_number]
        # #   error_message += "  #{node.type} on line #{line_number}\n"
        # # end
        puts error_message
      end
    end
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
