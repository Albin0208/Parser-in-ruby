module Runtime
  module Values
    class NullVal < RunTimeVal
      def initialize
        super('null', :null)
      end
    end
  end
end