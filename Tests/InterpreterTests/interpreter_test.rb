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
        # Test unary minus
        ast = UnaryExpr.new(NumericLiteral.new(5), :-)
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(-5, result.value)

        # Test logical negation
        ast = UnaryExpr.new(BooleanLiteral.new(true), :!)
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(BooleanVal, result)
        assert_equal(false, result.value)
    end

    def test_evaluate_binary_expr
        ast = BinaryExpr.new(NumericLiteral.new(3), :-, NumericLiteral.new(10))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(-7, result.value)

        ast = BinaryExpr.new(NumericLiteral.new(3), :*, NumericLiteral.new(10))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(30, result.value)

        ast = BinaryExpr.new(NumericLiteral.new(3.0), :/, NumericLiteral.new(10))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(0.3, result.value)

        ast = BinaryExpr.new(NumericLiteral.new(3), :%, NumericLiteral.new(2))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(1, result.value)

        # Test for precedence
        ast = BinaryExpr.new(NumericLiteral.new(3), :+, BinaryExpr.new(NumericLiteral.new(10), :*, NumericLiteral.new(2)))
        result = @interpreter.evaluate(ast, @env)
        assert_instance_of(NumberVal, result)
        assert_equal(23, result.value)
    end

    def test_evaluate_program
        # Declare variables
        ast1 = VarDeclaration.new(false, "x", NumericLiteral.new(5), "int")
        ast2 = VarDeclaration.new(false, "y", NumericLiteral.new(10), "int")

        # Assign to variable x
        ast3 = AssignmentExpr.new(NumericLiteral.new(7), Identifier.new("x"))

        # Calculate z = x + y
        ast4 = BinaryExpr.new(Identifier.new("x"), :+, Identifier.new("y"))
        ast5 = VarDeclaration.new(false, "z", ast4, "int")

        # Calculate t = z * 2
        ast6 = BinaryExpr.new(Identifier.new("z"), :*, NumericLiteral.new(2))
        ast7 = VarDeclaration.new(false, "t", ast6, "int")

        # Create program
        program = Program.new([ast1, ast2, ast3, ast5, ast7])

        # Evaluate program
        result = @interpreter.evaluate(program, @env)
        assert_instance_of(NumberVal, result)

        # Check variables
        assert_equal(7, @env.variables["x"].value)
        assert_equal(10, @env.variables["y"].value)
        assert_equal(17, @env.variables["z"].value)
        assert_equal(34, @env.variables["t"].value)
    end
end