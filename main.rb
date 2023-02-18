require_relative 'Parser/Parser.rb'
require_relative 'RunTime/Interpreter.rb'
require_relative 'RunTime/Enviroment.rb'

def main
    env = Enviroment.new()
    env.declareVar("true", BooleanVal.new(true), true)
    env.declareVar("false", BooleanVal.new(false), true)
    env.declareVar("null", NullVal.new(), true)
    
    parser = Parser.new()
    interpreter = Interpreter.new()
    input = ""
    while input != "exit"
        input = gets.chomp()

        program = parser.produceAST(input)
        p program
        puts program.to_s

        result = interpreter.evaluate(program, env)
        p result.to_s
    end
end

if __FILE__ == $0
    main()
end