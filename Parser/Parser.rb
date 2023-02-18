require_relative '../Lexer/Lexer.rb'
require_relative '../TokenType.rb'
require_relative '../Errors/Errors.rb'

class Parser
	def initialize
		@tokens = []
	end

	def produceAST(input)
		@tokens = Lexer.new(sourceCode).tokenize()
        puts @tokens.map(&:to_s).inspect # Display the tokens list
        program = Program.new([])

        # Parse until end of file
        while not_eof()
            program.body.append(parse_stmt())
        end

        return program
	end

	private

    # Check if we are not at the end of file
    def not_eof()
        return @tokens[0].type != TokenType::EOF 
    end

	def parse_stmt()
        case at().type
        when TokenType::LET, TokenType::CONST
            return parse_var_declaration()
        else
            return parse_expr()
        end
    end

	def at() 
        return @tokens[0]
    end

    def eat()
        prev = @tokens.shift()

        return prev
    end

    def expect(token_type)
        prev = eat()
        if !prev or prev.type != token_type
            raise "Parse error: Expected #{token_type} but got #{prev.type}"
        end

        return prev
    end
end