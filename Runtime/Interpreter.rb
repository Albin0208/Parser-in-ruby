require_relative '../AST_nodes/ast.rb'
require_relative 'Values.rb'
require_relative 'Eval/expressions.rb'
require_relative 'Eval/statements.rb'

class Interpreter
    def initialize()
        
    end

    def evaluate(astNode, env)
        case astNode.type
        when NODE_TYPES[:NumericLiteral]
            return NumberVal.new(astNode.value)
        when NODE_TYPES[:Identifier]
            return eval_identifier(astNode, env)
        when NODE_TYPES[:AssignmentExpr]
            return eval_assignment_expr(astNode, env)
        when NODE_TYPES[:LogicalAnd]
            return eval_logical_and_expr(astNode, env)
        when NODE_TYPES[:LogicalOr]
            return eval_logical_or_expr(astNode, env)
        when NODE_TYPES[:UnaryOperator]
            return eval_unary_expr(astNode, env)
        when NODE_TYPES[:BinaryExpr]
            return eval_binary_expr(astNode, env)
        when NODE_TYPES[:Program]
            return eval_program(astNode, env)
        when NODE_TYPES[:VarDeclaration]
            return eval_var_declaration(astNode, env)
        when NODE_TYPES[:IF]
            return eval_if_statement(astNode, env)
        else
            raise NotImplementedError.new("This AST Node has not yet been setup for #{astNode.type} #{astNode}")
        end
    end
end