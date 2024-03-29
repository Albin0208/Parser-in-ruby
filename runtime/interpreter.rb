require_relative '../ast_nodes/nodes'
require_relative 'environment'
require_relative 'values/values'
require_relative 'eval/evaluator_helpers'
require_relative 'eval/literal_evaluators'
require_relative 'eval/composite_evaluators'
require_relative 'eval/control_flow_evaluator'
require_relative 'eval/function_call_evaluator'
require_relative 'eval/program_structure_evaluators'
require_relative 'eval/other_evaluator'
require_relative 'signals/signals'

module Runtime
  #
  # The Interpreter class is responsible for running the program by evaluating each AST node.
  #
  class Interpreter
    include EvaluatorHelpers
    include LiteralEvaluators
    include CompositeEvaluators
    include ControlFlowEvaluator
    include FunctionCallEvaluator
    include ProgramStructureEvaluators
    include OtherEvaluator

    include Values

    #
    # Evaluates an AST node in the given environment.
    #
    # @param ast_node [Nodes::Stmt] the AST node to evaluate
    # @param env [Environment] the environment in which to evaluate the AST node
    #
    # @raise [NotImplementedError] if the current ast_node is not implemented
    #
    # @return [RunTimeVal] the value of evaluating the AST node
    #
    def evaluate(ast_node, env)
      evaluator = NODE_EVALUATORS[ast_node.type]

      return send(evaluator, ast_node, env) if evaluator

      raise NotImplementedError, "This AST Node has not yet been implemented: #{ast_node.type}"
    end

    private

    # A lookup table mapping node types to corresponding evaluation methods.
    NODE_EVALUATORS = {
      # Literal nodes
      NODE_TYPES[:NumericLiteral] => :eval_numeric_literal,
      NODE_TYPES[:String] => :eval_string_literal,
      NODE_TYPES[:Bool] => :eval_boolean_literal,
      NODE_TYPES[:Null] => :eval_null_literal,

      # Composite nodes
      NODE_TYPES[:HashLiteral] => :eval_hash_literal,
      NODE_TYPES[:ArrayLiteral] => :eval_array_literal,
      NODE_TYPES[:Identifier] => :eval_identifier,
      NODE_TYPES[:AssignmentExpr] => :eval_assignment_expr,
      NODE_TYPES[:LogicalAnd] => :eval_logical_and_expr,
      NODE_TYPES[:LogicalOr] => :eval_logical_or_expr,
      NODE_TYPES[:UnaryExpr] => :eval_unary_expr,
      NODE_TYPES[:BinaryExpr] => :eval_binary_expr,

      # Program structure nodes
      NODE_TYPES[:Program] => :eval_program,
      NODE_TYPES[:ClassInstance] => :eval_class_instance,
      NODE_TYPES[:ClassDeclaration] => :eval_class_declaration,
      NODE_TYPES[:VarDeclaration] => :eval_var_declaration,
      NODE_TYPES[:HashDeclaration] => :eval_hash_declaration,
      NODE_TYPES[:FuncDeclaration] => :eval_func_declaration,
      NODE_TYPES[:ArrayDeclaration] => :eval_array_declaration,

      # Function and method call nodes
      NODE_TYPES[:MethodCallExpr] => :eval_method_call_expr,
      NODE_TYPES[:PropertyCallExpr] => :eval_property_call_expr,
      NODE_TYPES[:CallExpr] => :eval_call_expr,

      # Control flow nodes
      NODE_TYPES[:ReturnStmt] => :eval_return_stmt,
      NODE_TYPES[:BreakStmt] => :eval_break_stmt,
      NODE_TYPES[:ContinueStmt] => :eval_continue_stmt,
      NODE_TYPES[:WHILE_LOOP] => :eval_while_stmt,
      NODE_TYPES[:FOR_LOOP] => :eval_for_stmt,
      NODE_TYPES[:FOR_EACH_LOOP] => :eval_for_each_stmt,
      NODE_TYPES[:IF] => :eval_if_statement,

      # Other nodes
      NODE_TYPES[:ContainerAccessor] => :eval_container_accessor
    }
  end
end
