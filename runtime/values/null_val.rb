require_relative 'runtime_val'

class NullVal < RunTimeVal
    def initialize
      super('null', :null)
    end
  end