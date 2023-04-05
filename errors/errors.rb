class CustomError < StandardError
    attr_reader :line_nr, :function, :file

    def initialize(mess, file = nil, line, column_nr, line_nr, function)
        super(mess.strip)
        @file = file
        @line = line
        @column_nr = column_nr
        @line_nr = line_nr
        @function = function
    end

    def set_file(file)
        @file = file
    end
end

class InvalidTokenError < CustomError
    def initialize(message, file, line, column_nr, line_nr, function)
        super(message, file, line, column_nr, line_nr, function)
    end
end

class EndOfInputError < CustomError
    def initialize(message, file, line, column_nr, line_nr, function)
        super(message, file, line, column_nr, line_nr, function)
    end
end

class UnmatchedParenthesisError < CustomError
    def initialize(message, file, line, column_nr, line_nr, function)
        super(message, file, line, column_nr, line_nr, function)
    end
end

class InvalidStringError < CustomError
    def initialize(message, file, line, column_nr, line_nr, function)
        super(message, file, line, column_nr, line_nr, function)
    end
end
