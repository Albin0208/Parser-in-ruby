require_relative 'Parser/Parser.rb'
require_relative 'Runtime/Interpreter.rb'
require_relative 'Runtime/Enviroment.rb'

def main
    env = Enviroment.new()
    
    debugging = ARGV[0] == "-debug"

    file = debugging ? ARGV[1] : ARGV[0]

    parser = Parser.new(debugging)
    interpreter = Interpreter.new()
    input = ""

    if not file.nil?
        program = parser.produce_ast(File.read(file))
        puts program.to_s unless not debugging

        result = interpreter.evaluate(program, env)

        program.display_info() unless not debugging
        puts result.to_s
    else
        while (input = STDIN.gets.chomp()) != "exit"
            program = parser.produce_ast(input)
            puts program.to_s unless not debugging

            result = interpreter.evaluate(program, env)

            program.display_info() unless not debugging
            puts result.to_s
        end
        puts "Bye!"
    end
end

if __FILE__ == $0
    main()
end