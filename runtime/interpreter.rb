require_relative '../ast_nodes/nodes'
require_relative 'values'
require_relative 'eval/expressions_evaluator'
require_relative 'eval/statements_evaluator'

#
# Represents a signal for a return statement in a function.
# @attr_reader return_node [RunTimeVal] the runtime val representing the value to be returned
#
class ReturnSignal < StandardError
  attr_reader :return_node
  #
  # Initializes a new ReturnSignal object.
  #
  # @param return_node [RunTimeVal] the runtime val representing the value to be returned
  #
  def initialize(return_node)
    super()
    @return_node = return_node
  end
end

#
# Represents a signal for a break statement in a loop.
#
class BreakSignal < StandardError
end

#
# Represents a signal for a continue statement in a loop.
#
class ContinueSignal < StandardError
end

class Interpreter
  include StatementsEvaluator
  include ExpressionsEvaluator

  #
  # Evaluates an AST node in the given environment.
  #
  # @param ast_node [Stmt] the AST node to evaluate
  # @param env [Environment] the environment in which to evaluate the AST node
  #
  # @raise [RuntimeError] if the type of the AST node is not recognized
  # @raise [NotImplementedError] if the current ast_node is not implemented
  # @raise [BreakSignal] if a 'break' statement is encountered
  # @raise [ContinueSignal] if a 'continue' statement is encountered
  #
  # @return [RunTimeVal] the value of evaluating the AST node
  #
  def evaluate(ast_node, env)
    case ast_node.type
    when NODE_TYPES[:NumericLiteral]
      NumberVal.new(ast_node.value, ast_node.numeric_type)
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
    when NODE_TYPES[:ClassInstance]
      eval_class_instance(ast_node, env)
    when NODE_TYPES[:ClassDeclaration]
      eval_class_declaration(ast_node, env)
    when NODE_TYPES[:VarDeclaration]
      eval_var_declaration(ast_node, env)
    when NODE_TYPES[:HashDeclaration]
      eval_hash_declaration(ast_node, env)
    when NODE_TYPES[:FuncDeclaration]
      eval_func_declaration(ast_node, env)
    when NODE_TYPES[:ArrayDeclaration]
      eval_array_declaration(ast_node, env)
    when NODE_TYPES[:MethodCallExpr]
      eval_method_call_expr(ast_node, env)
    when NODE_TYPES[:PropertyCallExpr]
      eval_property_call_expr(ast_node, env)
    when NODE_TYPES[:CallExpr]
      eval_call_expr(ast_node, env)
    when NODE_TYPES[:ReturnStmt]
      eval_return_stmt(ast_node, env)
    when NODE_TYPES[:BreakStmt]
      raise BreakSignal
    when NODE_TYPES[:ContinueStmt]
      raise ContinueSignal
    when NODE_TYPES[:WHILE_LOOP]
      eval_while_stmt(ast_node, env)
    when NODE_TYPES[:FOR_LOOP]
      eval_for_stmt(ast_node, env)
    when NODE_TYPES[:FOR_EACH_LOOP]
      eval_for_each_stmt(ast_node, env)
    when NODE_TYPES[:IF]
      eval_if_statement(ast_node, env)
    when NODE_TYPES[:ContainerAccessor]
      eval_container_accessor(ast_node, env)
    when NODE_TYPES[:Boolean]
      BooleanVal.new(ast_node.value)
    when NODE_TYPES[:HashLiteral]
      eval_hash_literal(ast_node, env)
    when NODE_TYPES[:ArrayLiteral]
      eval_array_literal(ast_node, env)
    when NODE_TYPES[:Null]
      NullVal.new
    else
      raise NotImplementedError, "This AST Node has not yet been setup for #{ast_node.type} #{ast_node}"
    end
  end
end
