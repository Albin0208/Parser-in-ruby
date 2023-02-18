NODE_TYPES = {
    # Statements
    Program: :Program,
    VarDeclaration: :VarDeclaration,
    # Expressions
    AssignmentExpr: :AssignmentExpr,
    BinaryExpr: :BinaryExpr,
    Identifier: :Identifier,
    NumericLiteral: :NumericLiteral
}

#####################################
#            Statements             #
#####################################

class Stmt
    attr_accessor :type
    def initialize(type)
        @type = type
    end

    def to_s
        raise "Error implement this"
    end
end

class Program < Stmt
    attr_accessor :body
    def initialize(body)
        super(NODE_TYPES[:Program])
        @body = body # A list of all statements
    end

    def to_s
        @body.each {|e| e.to_s}
    end
end

class VarDeclaration < Stmt
    attr_accessor :value, :identifier, :constant
    def initialize(constant, identifier, value)
        super(NODE_TYPES[:VarDeclaration])
        @constant = constant
        @identifier = identifier
        @value = value
    end

    def to_s
        return "Const: #{@constant}, Ident: #{@identifier}, Value: #{@value}"
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
    attr_accessor :value, :assigne
    def initialize(value, assigne)
        super(NODE_TYPES[:AssignmentExpr])
        @value = value
        @assigne = assigne
    end

    def to_s
        return "Value: #{@value}, Assigne: #{@assigne}"
    end
end

class BinaryExpr < Expr
    attr_accessor :left, :op, :right
    def initialize(left, op, right)
        super(NODE_TYPES[:BinaryExpr])
        @left = left
        @op = op
        @right = right
    end

    def to_s
        "(#{@left.to_s} #{@op} #{@right.to_s})"
    end
end

class Identifier < Expr
    attr_accessor :symbol
    def initialize(symbol)
        super(NODE_TYPES[:Identifier])
        @symbol = symbol
    end

    def to_s
        return @symbol
    end
end

class NumericLiteral < Expr
    attr_accessor :value
    def initialize(value)
        super(NODE_TYPES[:NumericLiteral])
        @value = value
    end

    def to_s
        @value.to_s
    end
end