require 'test/unit'
require_relative '../Lexer/Lexer.rb'
require_relative '../TokenType.rb'

class TestLexer < Test::Unit::TestCase
    def test_tokens
        input = "1"
        lexer = Lexer.new(input)

        assert_equal(TokenType::INTEGER, lexer.tokenize[0].type, "Assert that given a number a INTEGER token is returned")

        input = "11.34"
        lexer = Lexer.new(input)

        assert_equal(TokenType::FLOAT, lexer.tokenize[0].type, "Assert that given a decimal number a FLOAT token is returned")
        
        # Test that all the BINARYOPERATORs are converted to BINARYOPERATORs
        for op in ["+", "-", "*", "/"]
            lexer = Lexer.new(op)
            assert_equal(TokenType::BINARYOPERATOR, lexer.tokenize[0].type, "The token '#{op}' was not correctly tokenized")
        end

		for op in ["<", ">", ">=", "<=", "==", "!="]
			lexer = Lexer.new(op)
			assert_equal(TokenType::COMPARISON, lexer.tokenize[0].type, "The token '#{op}' was not correctly tokenized")
		end

		input = "-3"
        lexer = Lexer.new(input)

        assert_equal(TokenType::UNARYOPERATOR, lexer.tokenize[0].type, "Assert that given a negative number a unary operator is returned")
        
		input = "+3"
        lexer = Lexer.new(input)

        assert_equal(TokenType::UNARYOPERATOR, lexer.tokenize[0].type, "Assert that given a negative number a unary operator is returned")

        lexer = Lexer.new("()")
        assert_equal(TokenType::LPAREN, lexer.tokenize[0].type, "The token was not correctly tokenized")
        assert_equal(TokenType::RPAREN, lexer.tokenize[1].type, "The token was not correctly tokenized")
    end

	def test_tokenize_keywords
		input = "var"
		lexer = Lexer.new(input)

		assert_equal(TokenType::VAR, lexer.tokenize[0].type, "The token was not correctly tokenized")

		input = "const"
		lexer = Lexer.new(input)

		assert_equal(TokenType::CONST, lexer.tokenize[0].type, "The token was not correctly tokenized")

		input = "if"
		lexer = Lexer.new(input)

		assert_equal(TokenType::IF, lexer.tokenize[0].type, "The token was not correctly tokenized")

		input = "then"
		lexer = Lexer.new(input)

		assert_equal(TokenType::THEN, lexer.tokenize[0].type, "The token was not correctly tokenized")

		input = "end"
		lexer = Lexer.new(input)

		assert_equal(TokenType::ENDSTMT, lexer.tokenize[0].type, "The token was not correctly tokenized")
	end

	def test_tokenize_simple_input
		input = "1 + 2 * 3"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["INTEGER: 1, (1, 1)",
			"BINARYOPERATOR: +, (1, 3)",
			"INTEGER: 2, (1, 5)",
			"BINARYOPERATOR: *, (1, 7)",
			"INTEGER: 3, (1, 9)",
			"EOF: , (1, 10)"], tokens.map(&:to_s))
	end
	
	def test_tokenize_input_with_parentheses
		input = "1 + (2 * 3)"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["INTEGER: 1, (1, 1)",
			"BINARYOPERATOR: +, (1, 3)",
			"LPAREN: (, (1, 5)",
			"INTEGER: 2, (1, 6)",
			"BINARYOPERATOR: *, (1, 8)",
			"INTEGER: 3, (1, 10)",
			"RPAREN: ), (1, 11)",
			"EOF: , (1, 12)"], tokens.map(&:to_s))

		input = "1 + (2 * (3 + 4))"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["INTEGER: 1, (1, 1)",
			"BINARYOPERATOR: +, (1, 3)",
			"LPAREN: (, (1, 5)",
			"INTEGER: 2, (1, 6)",
			"BINARYOPERATOR: *, (1, 8)",
			"LPAREN: (, (1, 10)",
			"INTEGER: 3, (1, 11)",
			"BINARYOPERATOR: +, (1, 13)",
			"INTEGER: 4, (1, 15)",
			"RPAREN: ), (1, 16)",
			"RPAREN: ), (1, 17)",
			"EOF: , (1, 18)"], tokens.map(&:to_s))
	end
	
	def test_tokenize_input_with_whitespace
		input = " 1 + 2 *     3 * \t 5 "
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["INTEGER: 1, (1, 2)",
			"BINARYOPERATOR: +, (1, 4)",
			"INTEGER: 2, (1, 6)",
			"BINARYOPERATOR: *, (1, 8)",
			"INTEGER: 3, (1, 14)",
			"BINARYOPERATOR: *, (1, 16)",
			"INTEGER: 5, (1, 20)",
			"EOF: , (1, 21)"], tokens.map(&:to_s))
	end
	
	def test_tokenize_input_with_newlines
		input = "1 +\n2 *\n3"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["INTEGER: 1, (1, 1)",
			"BINARYOPERATOR: +, (1, 3)",
			"INTEGER: 2, (2, 1)",
			"BINARYOPERATOR: *, (2, 3)",
			"INTEGER: 3, (3, 1)",
			"EOF: , (3, 2)"], tokens.map(&:to_s))
	end
	
	def test_tokenize_input_with_invalid_character
		input = "1 + @ 2 * 3"
		lexer = Lexer.new(input)
		assert_raise(InvalidTokenError) { lexer.tokenize }
	end

	def test_tokenize_input_with_invalid_float
		input = "1 + 2. * 3"
		lexer = Lexer.new(input)
		assert_raise(InvalidTokenError) { lexer.tokenize }
	end
	
	def test_tokenize_input_with_invalid_integer
		input = "1 + 012 * 3"
		lexer = Lexer.new(input)
		assert_raise(InvalidTokenError) { lexer.tokenize }
	end

	def test_tokenize_input_with_invalid_parenthesis
		input = "1 + (2 * 3"
		lexer = Lexer.new(input)
		assert_raise(UnmatchedParenthesisError) { lexer.tokenize }

		input = "1 + (2 * 3) ("
		lexer = Lexer.new(input)
		assert_raise(UnmatchedParenthesisError) { lexer.tokenize }

		input = "1 + (2 * 3))"
		lexer = Lexer.new(input)
		assert_raise(UnmatchedParenthesisError) { lexer.tokenize }
	end

	def test_tokenize_input_with_comment
		input = " 1 + 2 * 3 # Add 3 * 4"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["INTEGER: 1, (1, 2)",
			"BINARYOPERATOR: +, (1, 4)",
			"INTEGER: 2, (1, 6)",
			"BINARYOPERATOR: *, (1, 8)",
			"INTEGER: 3, (1, 10)",
			"EOF: , (1, 12)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_var_decleration
		input = "var a = 5"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["VAR: var, (1, 1)",
			"IDENTIFIER: a, (1, 5)",
			"ASSIGN: =, (1, 7)",
			"INTEGER: 5, (1, 9)",
			"EOF: , (1, 10)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_const_var_decleration
		input = "const a = 5"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["CONST: const, (1, 1)",
			"IDENTIFIER: a, (1, 7)",
			"ASSIGN: =, (1, 9)",
			"INTEGER: 5, (1, 11)",
			"EOF: , (1, 12)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_reassign_var_decleration
		input = "a = 5"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["IDENTIFIER: a, (1, 1)",
			"ASSIGN: =, (1, 3)",
			"INTEGER: 5, (1, 5)",
			"EOF: , (1, 6)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_var_decleration_with_expr
		input = "var a = 10 / 5 + 4"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["VAR: var, (1, 1)",
			"IDENTIFIER: a, (1, 5)",
			"ASSIGN: =, (1, 7)",
			"INTEGER: 10, (1, 9)",
			"BINARYOPERATOR: /, (1, 12)",
			"INTEGER: 5, (1, 14)",
			"BINARYOPERATOR: +, (1, 16)",
			"INTEGER: 4, (1, 18)",
			"EOF: , (1, 19)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_reassign_var_decleration_with_var
		input = "a = 5 * y"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["IDENTIFIER: a, (1, 1)",
			"ASSIGN: =, (1, 3)",
			"INTEGER: 5, (1, 5)",
			"BINARYOPERATOR: *, (1, 7)",
			"IDENTIFIER: y, (1, 9)",
			"EOF: , (1, 10)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_unary_operator
		input = "-3 * 4 + -5"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["UNARYOPERATOR: -, (1, 1)",
			"INTEGER: 3, (1, 2)",
			"BINARYOPERATOR: *, (1, 4)",
			"INTEGER: 4, (1, 6)",
			"BINARYOPERATOR: +, (1, 8)",
			"UNARYOPERATOR: -, (1, 10)",
			"INTEGER: 5, (1, 11)",
			"EOF: , (1, 12)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_logical_operators
		input = "true && false"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["IDENTIFIER: true, (1, 1)",
			"LOGICAL: &&, (1, 6)",
			"IDENTIFIER: false, (1, 9)",
			"EOF: , (1, 14)"], tokens.map(&:to_s))

		input = "true || false"
		lexer = Lexer.new(input)
		tokens = lexer.tokenize
		assert_equal(["IDENTIFIER: true, (1, 1)",
			"LOGICAL: ||, (1, 6)",
			"IDENTIFIER: false, (1, 9)",
			"EOF: , (1, 14)"], tokens.map(&:to_s))
	end

	def test_tokenize_input_with_comparators
		for op in ["<", ">", ">=", "<=", "==", "!="]
			input = "3 #{op} 4"
			lexer = Lexer.new(input)
			tokens = lexer.tokenize
			assert_equal(["INTEGER: 3, (1, 1)",
				"COMPARISON: #{op}, (1, 3)",
				"INTEGER: 4, (1, #{4 + op.length})",
				"EOF: , (1, #{5 + op.length})"], tokens.map(&:to_s))
		end
	end
end