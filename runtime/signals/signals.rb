module Runtime
    #
  # Represents a signal for a return statement in a function.
  # @attr_reader return_node [RunTimeVal] the runtime val representing the value to be returned
  #
  class ReturnSignal < StandardError
    attr_reader :return_node
    #
    # Initializes a new ReturnSignal object.
    #
    # @param return_node [RunTimeVal] the runtime val representing the value to be returned
    #
    def initialize(return_node)
      super()
      @return_node = return_node
    end
  end

  #
  # Represents a signal for a break statement in a loop.
  #
  class BreakSignal < StandardError
  end

  #
  # Represents a signal for a continue statement in a loop.
  #
  class ContinueSignal < StandardError
  end
end