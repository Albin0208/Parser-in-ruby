# Class for keeping track of the different tokens
class Token
    attr_reader :type, :value, :line, :column

    def initialize(type, value, line, column)
        @type = type
        @value = value
        @line = line
        @column = column
    end
     
    def to_s()
        return "#{self.type}: #{self.value}, (#{@line}, #{@column})"
    end
end