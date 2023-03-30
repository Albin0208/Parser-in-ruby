NODE_TYPES = {
  # Statements
  Program: :Program,
  VarDeclaration: :VarDeclaration,
  IF: :IF,

  # Expressions
  AssignmentExpr: :AssignmentExpr,
  LogicalAnd: :LogicalAnd,
  LogicalOr: :LogicalOr,
  UnaryExpr: :UnaryExpr,
  BinaryExpr: :BinaryExpr,
  Identifier: :Identifier,
  NumericLiteral: :NumericLiteral,
  Boolean: :Boolean,
  String: :String,
  Null: :Null
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

# This class represents the ast node for a if statement
class IfStatement < Stmt
  attr_reader :body, :conditions, :else_body

  #
  # Creates an if statment node
  #
  # @param [Array] body A list of all the nodes inside the if body
  # @param [Expr] conditions The conditions of the if
  # @param [Array] else_body A list of all the nodes inside the else body
  #
  def initialize(body, conditions, else_body)
    super(NODE_TYPES[:IF])
    @body = body # A list of all statements
    @conditions = conditions
    @else_body = else_body
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
    return if @else_body.nil?

    puts "#{' ' * indent} Else body:"
    @else_body.each { |stmt| stmt.display_info(indent + 2) }
  end
end

#####################################
#           Expressions             #
#####################################

# This class represents the ast node for a expression
class Expr < Stmt
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
  attr_accessor :value

  #
  # Creates a numeric node
  #
  # @param [int, float] value The number the numeric node, can be an int or float
  #
  def initialize(value)
    super(NODE_TYPES[:NumericLiteral])
    @value = value
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