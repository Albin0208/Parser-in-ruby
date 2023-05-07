require_relative 'runtime_val'

module Values
  class NullVal < RunTimeVal
    def initialize
      super('null', :null)
    end
  end
end