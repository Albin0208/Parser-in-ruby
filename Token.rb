# Class for keeping track of the different tokens
class Token

    INTEGER = "INTEGER"
    PLUS = "PLUS"
    MINUS = "MINUS"
    MUL = "MUL"
    DIV = "DIV"
    LPAREN = "LPAREN"
    RPAREN = "RPAREN"
    attr_reader :type, :value

    def initialize(type, value, line, column)
        @type = type
        @value = value
        @line = line
        @column = column
    end
     
    def to_s()
        return "<#{self.type}: #{self.value}, (#{@line}, #{@column})"
    end
end