# NODE_TYPES represents the different types of nodes in the AST (Abstract Syntax Tree) used by the language.
#
# The AST is composed of different types of nodes, each representing a different part of the program's structure.
# The statement nodes represent program structures that have side effects, such as defining variables or loops,
# while the expression nodes represent computations that return a value.
NODE_TYPES = {
  # Statements
  Program: :Program,
  VarDeclaration: :VarDeclaration,
  HashDeclaration: :HashDeclaration,
  ArrayDeclaration: :ArrayDeclaration,
  FuncDeclaration: :FuncDeclaration,
  ClassDeclaration: :ClassDeclaration,
  ReturnStmt: :ReturnStmt,
  BreakStmt: :BreakStmt,
  ContinueStmt: :ContinueStmt,
  IF: :IF,
  ELSIF: :ELSIF,
  WHILE_LOOP: :WHILE_LOOP,
  FOR_LOOP: :FOR_LOOP,
  FOR_EACH_LOOP: :FOR_EACH_LOOP,

  # Expressions
  MethodCallExpr: :MethodCallExpr,
  PropertyCallExpr: :PropertyCallExpr,
  CallExpr: :CallExpr,
  ContainerAccessor: :ContainerAccessor,
  AssignmentExpr: :AssignmentExpr,
  LogicalAnd: :LogicalAnd,
  LogicalOr: :LogicalOr,
  UnaryExpr: :UnaryExpr,
  BinaryExpr: :BinaryExpr,
  Identifier: :Identifier,
  NumericLiteral: :NumericLiteral,
  HashLiteral: :HashLiteral,
  ArrayLiteral: :ArrayLiteral,
  Boolean: :Boolean,
  String: :String,
  Null: :Null,
  ClassInstance: :ClassInstance
}.freeze
  
NODE_TYPES_CONVERTER = {
  bool: :boolean,
}.freeze

Dir.glob(File.join(File.dirname(__FILE__), 'nodes/*.rb')).each { |f| require f }