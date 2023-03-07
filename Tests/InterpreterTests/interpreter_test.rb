require 'test/unit'
require_relative '../../Runtime/Interpreter.rb'

class TestInterpreter < Test::Unit::TestCase
    def setup
        @interpreter = Interpreter.new()
        @env = Enviroment.new()
    end

    def test_evaluate_numeric_literal
        ast = NumericLiteral.new(42)
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(42, result.value)

        # Test negative number
        ast = NumericLiteral.new(-42)
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(-42, result.value)
    end

    def test_evaluate_identifier
        @env.declareVar("x", NumberVal.new(10), false, "int")
        ast = Identifier.new("x")
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(10, result.value)
    end

    def test_evaluate_var_declaration
        ast = VarDeclaration.new(false, "x", NumericLiteral.new(5), "int")
        result = @interpreter.evaluate(ast, @env)
        assert_equal(5, result.value)
        assert_instance_of(NumberVal, @env.variables["x"])
        assert_equal(5, @env.variables["x"].value)
    end

    def test_evaluate_var_assignment_expr
        @env.declareVar("x", NumberVal.new(10), false, "int")
        ast = AssignmentExpr.new(NumericLiteral.new(5), Identifier.new("x"))
        result = @interpreter.evaluate(ast, @env)
        assert_equal(5, result.value)
        assert_instance_of(NumberVal, @env.variables["x"])
        assert_equal(5, @env.variables["x"].value)
    end

    def test_evaluate_logical_and
        # Test true && true
        ast = LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(true, result.value)

        # Test true && false
        ast = LogicalAndExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(false))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(false, result.value)

        # Test false && true
        ast = LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(false, result.value)

        # Test false && false
        ast = LogicalAndExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(false))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(false, result.value)
    end

    def test_evaluate_logical_or
        # Test true || true
        ast = LogicalOrExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(true))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(true, result.value)

        # Test true || false
        ast = LogicalOrExpr.new(BooleanLiteral.new(true), BooleanLiteral.new(false))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(true, result.value)
        
        # Test false || true
        ast = LogicalOrExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(true))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(true, result.value)

        # Test false || false
        ast = LogicalOrExpr.new(BooleanLiteral.new(false), BooleanLiteral.new(false))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(false, result.value)
    end

    def test_evaluate_unary_expr

    end

    def test_evaluate_binary_expr

    end

    def test_evaluate_program

    end
end