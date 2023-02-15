require 'test/unit'
require_relative 'Lexer'

class TestLexer < Test::Unit::TestCase
    def test_tokens
        input = "1"
        lexer = Lexer.new(input)

        assert_equal("integer", lexer.tokenize[0].type, "Assert that given a number a integer token is returned")
        
        # Test that all the operators are converted to operators
        for op in ["+", "-", "*", "/"]
            lexer = Lexer.new(op)

            assert_equal("operator", lexer.tokenize[0].type, "The token '#{op}' was not correctly tokenized")
        end

        lexer = Lexer.new("(")
        assert_equal("lparen", lexer.tokenize[0].type, "The token was not correctly tokenized")

        lexer = Lexer.new(")")
        assert_equal("rparen", lexer.tokenize[0].type, "The token was not correctly tokenized")
    end

    def test_tokenize_simple_input
        input = "1 + 2 * 3"
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["integer: 1, (1, 1)",
            "operator: +, (1, 3)",
            "integer: 2, (1, 5)",
            "operator: *, (1, 7)",
            "integer: 3, (1, 9)"])
      end
      
      def test_tokenize_input_with_parentheses
        input = "1 + (2 * 3)"
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["integer: 1, (1, 1)",
            "operator: +, (1, 3)",
            "lparen: (, (1, 5)",
            "integer: 2, (1, 6)",
            "operator: *, (1, 8)",
            "integer: 3, (1, 10)",
            "rparen: ), (1, 11)"])
      end
      
      def test_tokenize_input_with_whitespace
        input = " 1 + 2 * 3 "
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["integer: 1, (1, 2)",
            "operator: +, (1, 4)",
            "integer: 2, (1, 6)",
            "operator: *, (1, 8)",
            "integer: 3, (1, 10)"])
      end
      
      def test_tokenize_input_with_newlines
        input = "1 +\n2 *\n3"
        lexer = Lexer.new(input)
        tokens = lexer.tokenize
        assert_equal(tokens.map(&:to_s), 
            ["integer: 1, (1, 1)",
            "operator: +, (1, 3)",
            "integer: 2, (2, 1)",
            "operator: *, (2, 3)",
            "integer: 3, (3, 1)"])
      end
      
      def test_tokenize_input_with_invalid_character
        input = "1 + @ 2 * 3"
        lexer = Lexer.new(input)
        assert_raise(MySyntaxError) { lexer.tokenize }
      end
end