class InvalidTokenError < StandardError
    def initialize(message)
        super(message)
    end
end