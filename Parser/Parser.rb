require_relative '../AST_nodes/ast.rb'
require_relative '../Lexer/Lexer.rb'
require_relative '../TokenType.rb'
require_relative '../Errors/Errors.rb'

require 'logger'

class Parser
    def initialize(logging = false)
        @tokens = []
        @logging = logging

        @logger = Logger.new(STDOUT)
		@logger.level = logging ? Logger::DEBUG : Logger::FATAL
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
        when TokenType::CONST, TokenType::TYPE_SPECIFIER
            @logger.debug("(#{at().value}) matched var declaration")
            return parse_var_declaration()
        when TokenType::IF
            return parse_conditional()
        when TokenType::IDENTIFIER
            return parse_assignment_stmt()
        else
            return parse_expr()
        end
    end

    def parse_var_declaration()
        is_const = at().type == TokenType::CONST # Get if const keyword is present

        eat() if is_const # Eat the const keyword if we have a const
        type_specifier = eat().value # Get what type the var should be

        identifier = expect(TokenType::IDENTIFIER).value
        @logger.debug("Found indentifier from var declaration: #{identifier}")

        if at().type != TokenType::ASSIGN 
            if is_const
                @logger.error("Found Uninitialized constant")
                raise NameError.new("Uninitialized Constant. Constants must be initialize upon creation")
            else
                return VarDeclaration.new(is_const, identifier, nil, type_specifier)
            end
        end

        expect(TokenType::ASSIGN)
        expression = parse_expr()

        validate_type(expression, type_specifier) # Validate that the type is correct



        return VarDeclaration.new(is_const, identifier, expression, type_specifier)
    end

    # Validate that we are trying to assign a correct type to our variable.
    # @param expression - The expression we want to validate
    # @param type - What type we are trying to assign to
    def validate_type(expression, type)
        if !expression.instance_variables.include?(:@value) && expression.type != NODE_TYPES[:Identifier]
            @logger.debug("Validating left side of expression")
            validate_type(expression.left, type)
            if expression.instance_variables.include?(:@right)
                @logger.debug("Validating right side of expression")
                validate_type(expression.left, type)
            end
            return # If we get here the type is correct
        end
        case type
        when "int"
            # Make sure we either are assigning an integer or a variabel to the integer var
            if expression.type != NODE_TYPES[:NumericLiteral] && expression.type != NODE_TYPES[:Identifier]
                raise InvalidTokenError.new("Can't assign none numeric value to value of type #{type}")
            end
            # if expression.type == NODE_TYPES[:NumericLiteral] && expression.value.is_a?(Float)
            #     expression.value = expression.value.floor
            # end
        when "float"
            # Make sure we either are assigning a number or a variabel to the float var
            if expression.type != NODE_TYPES[:NumericLiteral] && expression.type != NODE_TYPES[:Identifier]
                raise InvalidTokenError.new("Can't assign none numeric value to value of type #{type}")
            end
        when "bool"
            # Make sure we either are assigning a bool or a variabel to the bool var
            if expression.type != NODE_TYPES[:Boolean] && expression.type != NODE_TYPES[:Identifier]
                raise InvalidTokenError.new("Can't assign none numeric value to value of type #{type}")
            end
        end
    end

    def parse_conditional()
        expect(TokenType::IF) # Eat the if token

        conditions = nil
        while at().type != TokenType::LBRACE # Parse the conditions of the if statment
            conditions = parse_logical_expr() # Add the condition expr to the conditions array
        end
        expect(TokenType::LBRACE) # Eat lbrace token
        # TODO Parse else if

        body = Array.new()
        while at().type != TokenType::RBRACE # Parse the content of teh if statment
            body.append(parse_stmt())
        end
        expect(TokenType::RBRACE)# Eat the rbrace token

        else_body = nil
        if at().type == TokenType::ELSE
            else_body = Array.new()
            eat() # Eat the Else token
            expect(TokenType::LBRACE) # Eat lbrace token
            while at().type != TokenType::RBRACE # Parse the conditions of the if statment
                else_body.append(parse_stmt()) # Add the condition expr to the conditions array
            end
            expect(TokenType::RBRACE)
        end

        return IfStatement.new(body, conditions, else_body)
    end

    def parse_assignment_stmt()
        @logger.debug("Parsing assign expression")
        identifier = parse_identifier()

        # Check if we have an assignment token
        if at().type == TokenType::ASSIGN
            eat()
            value = parse_expr() # Parse the right side
            return AssignmentExpr.new(value, identifier)
        end
        
        # Assignment not found so just return the identifier
        return identifier
    end

    def parse_expr()
        # case at().type
        # else
        return parse_logical_expr()
        # end
    end
    
    # Orders of Precedence (Lowests to highest)
    # AssignmentExpr
    # MemberExpr
    # FunctionCall
    # Logical
    # Comparison
    # AdditiveExpr
    # MultiplyExpr
    # UnaryExpr
    # PrimaryExpr


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
            right = parse_unary_expr()
            left = BinaryExpr.new(left, operator, right)
        end

        return left
    end

    def parse_unary_expr()
        while [:-, :+, :!].include?(at().value)
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
            return parse_identifier()
        when TokenType::INTEGER
            numLit = NumericLiteral.new(expect(TokenType::INTEGER).value.to_i)
            return numLit
        when TokenType::FLOAT
            numLit = NumericLiteral.new(expect(TokenType::FLOAT).value.to_f)
            return numLit
        when TokenType::BOOLEAN
            val = eat().value == "true" ? true : false
            return BooleanLiteral.new(val)
        when TokenType::LPAREN
            expect(TokenType::LPAREN) # Eat opening paren
            value = parse_expr()
            expect(TokenType::RPAREN) # Eat closing paren
            return value
        else
            raise InvalidTokenError.new("Unexpected token found: #{at().to_s}")
        end
    end

    # Parse a identifier and create a new identifier node
    # @return Identifier - The identifier node created
    def parse_identifier()
        id = expect(TokenType::IDENTIFIER) # Make sure we have a identifer
        @logger.debug("Found identifer: #{id.value}")
        return Identifier.new(id.value)
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
        @logger.debug("Eating token: #{at()}")
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