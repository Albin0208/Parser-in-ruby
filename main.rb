require_relative 'Parser/Parser.rb'
require_relative 'Runtime/Interpreter.rb'
require_relative 'Runtime/Enviroment.rb'

def main
    env = Enviroment.new()
    # env.declareVar("true", BooleanVal.new(true), true)
    # env.declareVar("false", BooleanVal.new(false), true)
    env.declareVar("null", NullVal.new(), true)
    
    debugging = ARGV[0] == "-debug"

    parser = Parser.new(debugging)
    interpreter = Interpreter.new()
    input = ""

    while (input = STDIN.gets.chomp()) != "exit"
        program = parser.produceAST(input)
        puts program.to_s unless not debugging

        result = interpreter.evaluate(program, env)

        program.display_info() unless not debugging
        p result.to_s
    end
    puts "Bye!"
end

if __FILE__ == $0
    main()
end