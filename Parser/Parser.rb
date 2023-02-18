require_relative '../AST_nodes/ast.rb'
require_relative '../Lexer/Lexer.rb'
require_relative '../TokenType.rb'
require_relative '../Errors/Errors.rb'

class Parser
    def initialize()
        @tokens = []
    end

    def produceAST(sourceCode)
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
        declaration = VarDeclaration.new(is_constant, identifier, parse_expr())

        return declaration
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
		left = parse_comparison_expr()

		while at().value == :"&&"
			comparetor = eat().value
			right = parse_comparison_expr()
            left = LogicalAndExpr.new(left, right)
		end

		while at().value == :"||"
			comparetor = eat().value
			right = parse_comparison_expr()
            left = LogicalOrExpr.new(left, right)
		end

		return left
	end

	def parse_comparison_expr()
		left = parse_additive_expr()

		while LogicComparison.include?(at().value)
			comparetor = eat().value
			right = parse_additive_expr()
            left = BinaryExpr.new(left, comparetor, right)
		end

		return left
	end

    def parse_additive_expr()
        left = parse_multiplication_expr()

        while at().value == :+ || at().value == :-
            operator = eat().value
            right = parse_multiplication_expr()
            left = BinaryExpr.new(left, operator, right)
        end

        return left
    end

    def parse_multiplication_expr()
        left = parse_unary_expr()

        while at().value == :* || at().value == :/ || at().value == :%
            operator = eat().value
            right = parse_primary_expr()
            left = BinaryExpr.new(left, operator, right)
        end

        return left
    end

    def parse_unary_expr()
		while at().value == :-
            operator = eat().value
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