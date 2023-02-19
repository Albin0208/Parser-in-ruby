require_relative '../AST_nodes/ast.rb'
require_relative '../Lexer/Lexer.rb'
require_relative '../TokenType.rb'
require_relative '../Errors/Errors.rb'

class Parser
    def initialize(logging = false)
        @tokens = []
        @logging = logging
    end

    # Produce a AST from the sourceCode
    # @param sourceCode - The string of code
    # @return Program - Return the top node in the AST
    def produceAST(sourceCode)
        @tokens = Lexer.new(sourceCode).tokenize()
        puts @tokens.map(&:to_s).inspect unless not @logging # Display the tokens list
        program = Program.new([])

        # Parse until end of file
        while not_eof()
            program.body.append(parse_stmt())
        end

        return program
    end

    private

    def parse_stmt()
        case at().type
        when TokenType::LET, TokenType::CONST
            return parse_var_declaration()
        else
            return parse_expr()
        end
    end

    def parse_var_declaration()
        is_constant = eat().type == TokenType::CONST
        identifier = expect(TokenType::IDENTIFIER).value

        if at().type != TokenType::ASSIGN 
            if is_constant
            raise "Must assign value to constat. No value provided"
            else
                return VarDeclaration.new(is_constant, identifier, nil)
            end
        end

        expect(TokenType::ASSIGN)
        expression = parse_expr()
        return VarDeclaration.new(is_constant, identifier, expression)
    end

    def parse_expr()
        return parse_assignment_expr()
    end
    
    # Orders of Prescidence (Lowests to highest)
    # AssignmentExpr
    # MemberExpr
    # FunctionCall
    # Logical
    # Comparison
    # AdditiveExpr
    # MultiplyExpr
    # UnaryExpr
    # PrimaryExpr

    def parse_assignment_expr()
        left = parse_logical_expr()

        if at().type == TokenType::ASSIGN
            eat()
            value = parse_assignment_expr()
            return AssignmentExpr.new(value, left)
        end
        
        return left
    end

    def parse_logical_expr()
        left = parse_logical_and_expr()

        # Check for logical or
        while at().value == :"||"
            eat().value # Eat the operator
            right = parse_logical_and_expr()
            left = LogicalOrExpr.new(left, right)
        end
        
        return left
    end

    def parse_logical_and_expr()
        left = parse_comparison_expr()
        
        # Check for logical and
        while at().value == :"&&"
          eat().value # Eat the operator
          right = parse_comparison_expr()
          left = LogicalAndExpr.new(left, right)
        end
      
        return left
    end

	def parse_comparison_expr()
		left = parse_additive_expr()

		while LOGICCOMPARISON.include?(at().value)
			comparetor = eat().value # Eat the comparetor
			right = parse_additive_expr()
            left = BinaryExpr.new(left, comparetor, right)
		end

		return left
	end

    def parse_additive_expr()
        left = parse_multiplication_expr()

        while ADD_OPS.include?(at().value)
            operator = eat().value # Eat the operator
            right = parse_multiplication_expr()
            left = BinaryExpr.new(left, operator, right)
        end

        return left
    end

    def parse_multiplication_expr()
        left = parse_unary_expr()

        while MULT_OPS.include?(at().value)
            operator = eat().value # Eat the operator
            right = parse_primary_expr()
            left = BinaryExpr.new(left, operator, right)
        end

        return left
    end

    def parse_unary_expr()
        while at().value == :-
            operator = eat().value # Eat the operator
            right = parse_primary_expr()
            return UnaryExpr.new(right, operator)
        end

		return parse_primary_expr()
    end

    def parse_primary_expr()
        tok = at().type
        case tok
        when TokenType::IDENTIFIER
            ident = Identifier.new(eat().value)
            return ident
        when TokenType::INTEGER, TokenType::FLOAT
            numLit = NumericLiteral.new(eat().value)
            return numLit
        when TokenType::LPAREN
            eat() # Eat opening paren
            value = parse_expr()
            eat() # Eat closing paren
            return value
        else
            raise InvalidTokenError.new("Unexpected token found: #{at().to_s}")
        end
    end

    ##################################################
	# 				Helper functions				 #
	##################################################

    # Check if we are not at the end of file
    # @return Boolean - Return of we are at the end of file or not
    def not_eof()
        return at().type != TokenType::EOF 
    end

    # Get what token we are at
    # @return Token - What token we have right now
    def at() 
        return @tokens[0]
    end

    # Eat the next token
    # @return Token - The token eaten
    def eat()
        return @tokens.shift()
    end

    # Eat the next token and make sure we have eaten the correct type
    # @param token_type - What type of token we are expecting
    # @return Token - Returns the expected token
    def expect(token_type)
        prev = eat()
        if !prev or prev.type != token_type
            raise "Parse error: Expected #{token_type} but got #{prev.type}"
        end
        return prev
    end
end