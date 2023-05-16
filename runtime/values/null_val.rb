module Runtime
  module Values    #
    # Represents the runtime value of `null`.
    #
    class NullVal < RunTimeVal
      #
      # Creates a new `NullVal` instance.
      #
      def initialize
        super('null', :null)
      end
    end
  end
end
