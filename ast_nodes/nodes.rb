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
    FuncDeclaration: :FuncDeclaration,
    ClassDeclaration: :ClassDeclaration,
    ReturnStmt: :ReturnStmt,
    BreakStmt: :BreakStmt,
    ContinueStmt: :ContinueStmt,
    IF: :IF,
    ELSIF: :ELSIF,
    WHILE_LOOP: :WHILE_LOOP,
    FOR_LOOP: :FOR_LOOP,
  
    # Expressions
    MethodCallExpr: :MethodCallExpr,
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
    Boolean: :Boolean,
    String: :String,
    Null: :Null
  }.freeze
  
  NODE_TYPES_CONVERTER = {
    bool: :boolean,
    # int: :number,
    # float: :number,
    string: :string
  }.freeze

Dir.glob(File.join(File.dirname(__FILE__), 'nodes/*.rb')).each { |f| require f }