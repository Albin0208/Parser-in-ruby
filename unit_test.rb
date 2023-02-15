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

    def test_simple_expression
        expression = "1 + 3"
        lexer = Lexer.new(expression)
        tokens = lexer.tokenize

        assert_equal(3, tokens.length, "Assert that we get three tokens")
        assert_equal("integer", tokens[0].type, "Assert that given a number a integer token is returned")
        assert_equal("operator", tokens[1].type, "Assert that given a number a integer token is returned")
        assert_equal("integer", tokens[2].type, "Assert that given a number a integer token is returned")
    end

    def test_bigger_expression
        expression = "1 + 3 * 4 + 3"
        lexer = Lexer.new(expression)
        tokens = lexer.tokenize

        assert_equal(7, tokens.length, "Assert that we get 7 tokens")
        assert_equal("integer", tokens[0].type)
        assert_equal("operator", tokens[1].type)
        assert_equal("integer", tokens[2].type)
        assert_equal("operator", tokens[3].type)
        assert_equal("integer", tokens[4].type)
        assert_equal("operator", tokens[5].type)
        assert_equal("integer", tokens[6].type)
    end

    def test_expresstion_with_parens
        expression = "1 + 3 * (4 + 3)"
        lexer = Lexer.new(expression)
        tokens = lexer.tokenize

        assert_equal(9, tokens.length, "Assert that we get 9 tokens")
        assert_equal("integer", tokens[0].type)
        assert_equal("operator", tokens[1].type)
        assert_equal("integer", tokens[2].type)
        assert_equal("operator", tokens[3].type)
        assert_equal("lparen", tokens[4].type)
        assert_equal("integer", tokens[5].type)
        assert_equal("operator", tokens[6].type)
        assert_equal("integer", tokens[7].type)
        assert_equal("rparen", tokens[8].type)
    end
end