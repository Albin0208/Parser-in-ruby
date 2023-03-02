NODE_TYPES = {
    # Statements
    Program: :Program,
    VarDeclaration: :VarDeclaration,
    IF: :IF,
  
    # Expressions
    AssignmentExpr: :AssignmentExpr,
    LogicalAnd: :LogicalAnd,
    LogicalOr: :LogicalOr,
    UnaryOperator: :UnaryOperator,
    BinaryExpr: :BinaryExpr,
    Identifier: :Identifier,
    NumericLiteral: :NumericLiteral,
    Boolean: :Boolean
}

#####################################
#            Statements             #
#####################################

class Stmt
    attr_reader :type
    def initialize(type)
        @type = type
    end

    def to_s
        raise NotImplementedError.new("to_s method is not implemented for #{self.class}")
    end

    def display_info(indent = 0)
        raise NotImplementedError.new("display_info method is not implemented for #{self.class}")
    end
end

class Program < Stmt
    attr_reader :body
    def initialize(body)
        super(NODE_TYPES[:Program])
        @body = body # A list of all statements
    end

    def to_s
        return @body.map(&:to_s)
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}"
        @body.each { |stmt| stmt.display_info(indent + 2) }
    end
end

class VarDeclaration < Stmt
    attr_reader :value, :identifier, :constant, :value_type
    def initialize(constant, identifier, value = nil, value_type)
        super(NODE_TYPES[:VarDeclaration])
        @constant = constant
        @identifier = identifier
        @value = value
        @value_type = value_type 
    end

    def to_s
        return "Const: #{@constant}, Ident: #{@identifier}, Value: #{@value}"
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@constant} #{@identifier}"
        @value.display_info(indent + 2) if @value
    end
end

class IfStatement < Stmt
    attr_reader :body, :conditions, :else_body
    def initialize(body, conditions, else_body)
        super(NODE_TYPES[:IF])
        @body = body # A list of all statements
        @conditions = conditions # A list of all the conditions
        @else_body = else_body
    end

    def to_s
        return @body.map(&:to_s)
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}"
        puts "#{" " * indent} Conditions:"
        @conditions.display_info(indent + 2)
        @body.each { |stmt| stmt.display_info(indent + 2) }
        if @else_body != nil
            puts "#{" " * indent} Else body:"
            @else_body.each { |stmt| stmt.display_info(indent + 2) }
        end
    end
end

#####################################
#           Expressions             #
#####################################

class Expr < Stmt
    def initialize(type)
        super(type)
    end
end

class AssignmentExpr < Expr
    attr_reader :value, :assigne
    def initialize(value, assigne)
        super(NODE_TYPES[:AssignmentExpr])
        @value = value
        @assigne = assigne
    end

    def to_s
        return "Value: #{@value}, Assigne: #{@assigne}"
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@assigne}"
        @value.display_info(indent + 2)
    end
end

class UnaryExpr < Expr
    attr_reader :left, :op
    def initialize(left, op)
        super(NODE_TYPES[:UnaryOperator])
        @left = left
        @op = op
    end

    def to_s
        "(#{@op}#{@left.to_s})"
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@op}"
        @left.display_info(indent + 2)
    end
end

class BinaryExpr < Expr
    attr_reader :left, :op, :right
    def initialize(left, op, right)
        super(NODE_TYPES[:BinaryExpr])
        @left = left
        @op = op
        @right = right
    end

    def to_s
        "(#{@left.to_s} #{@op} #{@right.to_s})"
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@op}"
        @left.display_info(indent + 2)
        @right.display_info(indent + 2)
    end
end

class Identifier < Expr
    attr_reader :symbol
    def initialize(symbol)
        super(NODE_TYPES[:Identifier])
        @symbol = symbol
    end

    def to_s
        return @symbol
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@symbol}"
    end
end

class NumericLiteral < Expr
    attr_reader :value
    def initialize(value)
        super(NODE_TYPES[:NumericLiteral])
        @value = value
    end

    def to_s
        @value.to_s
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@value}"
    end
end

class BooleanLiteral < Expr
    attr_reader :value
    def initialize(value)
        super(NODE_TYPES[:Boolean])
        @value = value
    end

    def to_s
        @value.to_s
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}: #{@value}"
    end
end

class LogicalAndExpr < Expr
    attr_reader :left, :right
    def initialize(left, right)
        super(NODE_TYPES[:LogicalAnd])
        @left = left
        @op = :"&&"
        @right = right
    end

    def to_s
        "(#{@left.to_s} && #{@right.to_s})"
    end

    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}"
        @left.display_info(indent + 2)
        @right.display_info(indent + 2)
    end
end

class LogicalOrExpr < Expr
    attr_reader :left, :right
    def initialize(left, right)
        super(NODE_TYPES[:LogicalOr])
        @left = left
        @op = :"||"
        @right = right
    end

    def to_s
        "(#{@left.to_s} || #{@right.to_s})"
    end
    
    def display_info(indent = 0)
        puts "#{" " * indent} #{self.class.name}"
        @left.display_info(indent + 2)
        @right.display_info(indent + 2)
    end
end