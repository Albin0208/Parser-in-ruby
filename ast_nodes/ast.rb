NODE_TYPES = {
  # Statements
  Program: :Program,
  VarDeclaration: :VarDeclaration,
  HashDeclaration: :HashDeclaration,
  FuncDeclaration: :FuncDeclaration,
  ReturnStmt: :ReturnStmt,
  IF: :IF,
  ELSIF: :ELSIF,
  WHILE_LOOP: :WHILE_LOOP,

  # Expressions
  MethodCallExpr: :MethodCallExpr,
  CallExpr: :CallExpr,
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

#####################################
#            Statements             #
#####################################

# This Class represents a statment inside the parser tree
class Stmt
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def to_s
    raise NotImplementedError, "to_s method is not implemented for #{self.class}"
  end

  def display_info(_indent = 0)
    raise NotImplementedError, "display_info method is not implemented for #{self.class}"
  end
end

# This class represents the ast node for the program
class Program < Stmt
  attr_reader :body

  def initialize(body)
    super(NODE_TYPES[:Program])
    @body = body # A list of all statements
  end

  def to_s
    @body.map(&:to_s)
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

# This class represents the ast node for a variable declaration
class VarDeclaration < Stmt
  attr_reader :value, :identifier, :constant, :value_type

  #
  # Creates an var declaration node
  #
  # @param [Boolean] constant If this var should be a constant
  # @param [Identifier] identifier The identifier for the var
  # @param [<Type>] value_type What type this var is
  # @param [Expr] value The value that should be assigned or nil if only declaring
  #
  def initialize(constant, identifier, value_type, value = nil)
    super(NODE_TYPES[:VarDeclaration])
    @constant = constant
    @identifier = identifier
    @value_type = value_type
    @value = value
  end

  def to_s
    "Const: #{@constant}, Ident: #{@identifier}, Value: #{@value}, Type: #{@value_type}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@constant} #{@identifier} #{@value_type}"
    @value&.display_info(indent + 2)
  end
end

class HashDeclaration < Stmt
  attr_reader :value, :identifier, :constant, :key_type, :value_type

  #
  # Creates an hash declaration node
  #
  # @param [Boolean] constant If this var should be a constant
  # @param [Identifier] identifier The identifier for the var
  # @param [string] key_type What type the key has
  # @param [string] value_type What type the value is
  # @param [Expr] value The value that should be assigned or nil if only declaring
  #
  def initialize(constant, identifier, key_type, value_type, value = nil)
    super(NODE_TYPES[:HashDeclaration])
    @constant = constant
    @identifier = identifier
    @key_type = key_type
    @value_type = value_type
    @value = value
  end

  def to_s
    "Const: #{@constant}, Ident: #{@identifier}, Value: #{@value}, Type: #{@value_type}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@constant} #{@identifier}"
    puts "#{' ' * (indent + 2)} Key type: #{@key_type}"
    puts "#{' ' * (indent + 2)} Value type: #{@value_type}"
    puts "#{' ' * (indent + 2)} Value:"
    @value&.display_info(indent + 2)
  end
end

class FuncDeclaration < Stmt
  attr_reader :type_specifier, :identifier, :params, :body
  attr_accessor :env

  def initialize(type_specifier, identifier, params, body)
    super(NODE_TYPES[:FuncDeclaration])
    @type_specifier = type_specifier
    @identifier = identifier
    @params = params
    @body = body
  end

  def to_s
    "Type: #{@type_specifier}, Ident: #{@identifier}, Params: #{@params}, body: #{@body}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * indent} Return type: #{@type_specifier}"
    puts "#{' ' * indent} Params:"
    @params.each { |param| param.display_info(indent + 2) unless @params.empty? }
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

class ReturnStmt < Stmt
  attr_reader :return_type, :body

  def initialize(body)
    super(NODE_TYPES[:ReturnStmt])
    @body = body
  end

  def to_s
    "Return Body: #{@body}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    # puts "#{' ' * indent} Return type: #{@type_specifier}"
    puts "#{' ' * indent} Body:"
    #@body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

class WhileStmt < Stmt
  attr_reader :body, :conditions

  #
  # Creates an While statment node
  #
  # @param [Array] body A list of all the nodes inside the while loop
  # @param [Expr] conditions The conditions of the loop
  #
  def initialize(body, conditions)
    super(NODE_TYPES[:WHILE_LOOP])
    @body = body # A list of all statements
    @conditions = conditions
  end

  def to_s
    @body.map(&:to_s)
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * indent} Conditions:"
    @conditions.display_info(indent + 2)
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

# This class represents the ast node for a if statement
class IfStatement < Stmt
  attr_reader :body, :conditions, :else_body, :elsif_stmts

  #
  # Creates an if statment node
  #
  # @param [Array] body A list of all the nodes inside the if body
  # @param [Expr] conditions The conditions of the if
  # @param [Array] else_body A list of all the nodes inside the else body
  # @param [Array] elsif_stmts A list of all the elsif statements
  #
  def initialize(body, conditions, else_body, elsif_stmts)
    super(NODE_TYPES[:IF])
    @body = body # A list of all statements
    @conditions = conditions
    @else_body = else_body
    @elsif_stmts = elsif_stmts
  end

  def to_s
    @body.map(&:to_s)
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * indent} Conditions:"
    @conditions.display_info(indent + 2)
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }

    unless @elsif_stmts.nil?
      puts "#{' ' * indent} Elsifs:"
      @elsif_stmts.each { |stmt| stmt.display_info(indent + 2) }
    end

    return if @else_body.nil?

    puts "#{' ' * indent} Else body:"
    @else_body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

# This class represents the ast node for a elsif statement
class ElsifStatement < Stmt
  attr_reader :body, :conditions

  #
  # Creates an elsif statment node
  #
  # @param [Array] body A list of all the nodes inside the if body
  # @param [Expr] conditions The conditions of the if
  #
  def initialize(body, conditions)
    super(NODE_TYPES[:ELSIF])
    @body = body # A list of all statements
    @conditions = conditions
  end

  def to_s
    @body.map(&:to_s)
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * indent} Conditions:"
    @conditions.display_info(indent + 2)
    puts "#{' ' * indent} Body:"
    @body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

#####################################
#           Expressions             #
#####################################

# This class represents the ast node for a expression
class Expr < Stmt
end

class MethodCallExpr < Expr
  attr_reader :expr, :method_name, :params

  #
  # Creates the callexpr node
  #
  # @param [String] func_name The name of the function to call
  # @param [Array] params A list of params that should be sent to the function later
  #
  def initialize(expr, method_name, params)
    super(NODE_TYPES[:MethodCallExpr])
    @expr = expr
    @method_name = method_name
    @params = params
  end

  def to_s
    "Method name: #{@method_name}, Params: #{@params}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * (indent + 2)} Expr: #{expr.display_info(indent + 2)}"
    puts "#{' ' * (indent + 2)} Method name: #{method_name}"
    puts "#{' ' * indent} Params:"
    @params.each { |param| param.display_info(indent + 2) unless @params.empty? }
  end
end

#
# The ast node for a call expression to a function
#
class CallExpr < Expr
  attr_reader :func_name, :params

  #
  # Creates the callexpr node
  #
  # @param [String] func_name The name of the function to call
  # @param [Array] params A list of params that should be sent to the function later
  #
  def initialize(func_name, params)
    super(NODE_TYPES[:CallExpr])
    @func_name = func_name
    @params = params
  end

  def to_s
    "Func name: #{@func_name}, Params: #{@params}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * (indent + 2)} Func name: #{func_name}"
    puts "#{' ' * indent} Params:"
    @params.each { |param| param.display_info(indent + 2) unless @params.empty? }
  end
end

# This class represents the ast node for a assignment expression
class AssignmentExpr < Expr
  attr_reader :value, :assigne

  #
  # Creates an assignment expression
  #
  # @param [Expr] value The expr we want the result of to assign to the variable
  # @param [Identifier] assigne To what identifier we want to do the assignment to
  #
  def initialize(value, assigne)
    super(NODE_TYPES[:AssignmentExpr])
    @value = value
    @assigne = assigne
  end

  def to_s
    "Value: #{@value}, Assigne: #{@assigne}"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@assigne}"
    @value.display_info(indent + 2)
  end
end

# This class represents the ast node for a unary expression
class UnaryExpr < Expr
  attr_reader :left, :op

  #
  # Creates a unary expression
  #
  # @param [Expr] left The expression
  # @param [Symbol] op The operator for the expression
  #
  def initialize(left, op)
    super(NODE_TYPES[:UnaryExpr])
    @left = left
    @op = op
  end

  def to_s
    "(#{@op}#{@left})"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@op}"
    @left.display_info(indent + 2)
  end
end

# This class represents the ast node for a binary expression
class BinaryExpr < Expr
  attr_reader :left, :op, :right

  #
  # Creates a binary expression node
  #
  # @param [Expr] left The left side of the expression
  # @param [Symbol] op The operator to be used for the expression
  # @param [Expr] right The right side of the expression
  #
  def initialize(left, op, right)
    super(NODE_TYPES[:BinaryExpr])
    @left = left
    @op = op
    @right = right
  end

  def to_s
    "(#{@left} #{@op} #{@right})"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@op}"
    @left.display_info(indent + 2)
    @right.display_info(indent + 2)
  end
end

# This class represents the ast node for a identifier
class Identifier < Expr
  attr_reader :symbol

  #
  # Creates an identifier node
  #
  # @param [Symbol] symbol A symbol of the name for the identifier
  #
  def initialize(symbol)
    super(NODE_TYPES[:Identifier])
    @symbol = symbol
  end

  def to_s
    @symbol
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@symbol}"
  end
end

# This class represents the ast node for a numericliteral
class NumericLiteral < Expr
  attr_accessor :value, :numeric_type

  #
  # Creates a numeric node
  #
  # @param [int, float] value The number the numeric node, can be an int or float
  #
  def initialize(value, type)
    super(NODE_TYPES[:NumericLiteral])
    @value = value
    @numeric_type = type
  end

  def to_s
    @value.to_s
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@value}"
  end
end

# This class represents the ast node for a booleanliteral
class BooleanLiteral < Expr
  attr_reader :value

  #
  # Creates a boolean node
  #
  # @param [Boolean] value The value of the boolean, true or false
  #
  def initialize(value)
    super(NODE_TYPES[:Boolean])
    @value = value
  end

  def to_s
    @value.to_s
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@value}"
  end
end

# This class represents the ast node for a stringliteral
class StringLiteral < Expr
  attr_reader :value

  #
  # Creates a string node
  #
  # @param [String] value The value of the string node
  #
  def initialize(value)
    super(NODE_TYPES[:String])
    @value = value
  end

  def to_s
    "\"#{@value}\""
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@value}"
  end
end

# This class represents the ast node for a null literal
class NullLiteral < Expr
  attr_reader :value

  #
  # Creates a null node
  #
  def initialize
    super(NODE_TYPES[:Null])
    @value = 'null'
  end

  def to_s
    @value.to_s
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}: #{@value}"
  end
end

class HashLiteral < Expr
  attr_reader :key_value_pairs

  #
  # Create a new HashLiteral
  #
  # @param [Array] key_value_pairs The list of all key value pairs
  #
  def initialize(key_value_pairs)
    super(NODE_TYPES[:HashLiteral])
    @key_value_pairs = key_value_pairs
  end

  def to_s
    "HashLiteral"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    @key_value_pairs.each() { |pair| puts "#{' ' * (indent + 2)} Key: #{pair[:key]} Value: #{pair[:value]}" }
  end
end

# This class represents the ast node for a logical and expression
class LogicalAndExpr < Expr
  attr_reader :left, :right, :op

  #
  # Creates a logical and node
  #
  # @param [Stmt] left The left side of the and expression
  # @param [Stmt] right The right side of the and expression
  #
  def initialize(left, right)
    super(NODE_TYPES[:LogicalAnd])
    @left = left
    @op = :"&&"
    @right = right
  end

  def to_s
    "(#{@left} && #{@right})"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    @left.display_info(indent + 2)
    @right.display_info(indent + 2)
  end
end

# This class represents the ast node for a logical or expression
class LogicalOrExpr < Expr
  attr_reader :left, :right, :op

  #
  # Creates a logical or node
  #
  # @param [Stmt] left The left side of the or expression
  # @param [Stmt] right The right side of the or expression
  #
  def initialize(left, right)
    super(NODE_TYPES[:LogicalOr])
    @left = left
    @op = :"||"
    @right = right
  end

  def to_s
    "(#{@left} || #{@right})"
  end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    @left.display_info(indent + 2)
    @right.display_info(indent + 2)
  end
end
