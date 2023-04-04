require_relative '../ast_nodes/ast'
require_relative 'values'
require_relative 'eval/expressions'
require_relative 'eval/statements'

class Interpreter
  def initialize; end

  def evaluate(ast_node, env)
    case ast_node.type
    when NODE_TYPES[:NumericLiteral]
      NumberVal.new(ast_node.value)
    when NODE_TYPES[:String]
      StringVal.new(ast_node.value)
    when NODE_TYPES[:Identifier]
      eval_identifier(ast_node, env)
    when NODE_TYPES[:AssignmentExpr]
      eval_assignment_expr(ast_node, env)
    when NODE_TYPES[:LogicalAnd]
      eval_logical_and_expr(ast_node, env)
    when NODE_TYPES[:LogicalOr]
      eval_logical_or_expr(ast_node, env)
    when NODE_TYPES[:UnaryExpr]
      eval_unary_expr(ast_node, env)
    when NODE_TYPES[:BinaryExpr]
      eval_binary_expr(ast_node, env)
    when NODE_TYPES[:Program]
      eval_program(ast_node, env)
    when NODE_TYPES[:VarDeclaration]
      eval_var_declaration(ast_node, env)
    when NODE_TYPES[:FuncDeclaration]
      eval_func_declaration(ast_node, env)
    when NODE_TYPES[:CallExpr]
      eval_call_expr(ast_node, env)
    when NODE_TYPES[:ReturnStmt]
      eval_return_stmt(ast_node, env)
    when NODE_TYPES[:IF]
      eval_if_statement(ast_node, env)
    when NODE_TYPES[:Boolean]
      BooleanVal.new(ast_node.value)
    when NODE_TYPES[:Null]
      NullVal.new
    else
      raise NotImplementedError, "This AST Node has not yet been setup for #{ast_node.type} #{ast_node}"
    end
  end
end
