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
        
        # Test that all the operators are converted to operators
        for op in ["+", "-", "*", "/"]
            lexer = Lexer.new(op)
            assert_equal(TokenType::OPERATOR, lexer.tokenize[0].type, "The token '#{op}' was not correctly tokenized")
        end

        lexer = Lexer.new("()")
        assert_equal(TokenType::LPAREN, lexer.tokenize[0].type, "The token was not correctly tokenized")
        assert_equal(TokenType::RPAREN, lexer.tokenize[1].type, "The token was not correctly tokenized")
    end

    def test_tokenize_simple_input
        input = "1 + 2 * 3"
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["INTEGER: 1, (1, 1)",
            "OPERATOR: +, (1, 3)",
            "INTEGER: 2, (1, 5)",
            "OPERATOR: *, (1, 7)",
            "INTEGER: 3, (1, 9)",
            "EOF: , (1, 10)"])
      end
      
      def test_tokenize_input_with_parentheses
        input = "1 + (2 * 3)"
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["INTEGER: 1, (1, 1)",
            "OPERATOR: +, (1, 3)",
            "LPAREN: (, (1, 5)",
            "INTEGER: 2, (1, 6)",
            "OPERATOR: *, (1, 8)",
            "INTEGER: 3, (1, 10)",
            "RPAREN: ), (1, 11)",
            "EOF: , (1, 12)"])
      end
      
      def test_tokenize_input_with_whitespace
        input = " 1 + 2 * 3 "
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["INTEGER: 1, (1, 2)",
            "OPERATOR: +, (1, 4)",
            "INTEGER: 2, (1, 6)",
            "OPERATOR: *, (1, 8)",
            "INTEGER: 3, (1, 10)",
            "EOF: , (1, 11)"])
      end
      
      def test_tokenize_input_with_newlines
        input = "1 +\n2 *\n3"
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["INTEGER: 1, (1, 1)",
            "OPERATOR: +, (1, 3)",
            "INTEGER: 2, (2, 1)",
            "OPERATOR: *, (2, 3)",
            "INTEGER: 3, (3, 1)",
            "EOF: , (3, 2)"])
      end
      
      def test_tokenize_input_with_invalid_character
        input = "1 + @ 2 * 3"
        lexer = Lexer.new(input)
        assert_raise(InvalidTokenError) { lexer.tokenize }
      end

      def test_tokenize_input_with_invalid_parenthesis
        input = "1 + (2 * 3"
        lexer = Lexer.new(input)
        assert_raise(UnmatchedParenthesisError) { lexer.tokenize }

        input = "1 + (2 * 3))"
        lexer = Lexer.new(input)
        assert_raise(UnmatchedParenthesisError) { lexer.tokenize }
      end
end