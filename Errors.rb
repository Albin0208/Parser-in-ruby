class MySyntaxError < StandardError
    def initialize(message)
        super("Syntax error: #{message}")
    end
end