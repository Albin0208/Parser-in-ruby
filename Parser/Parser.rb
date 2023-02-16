require_relative '../Lexer/Lexer.rb'

class Node
  def eval
    raise NotImplementedError
  end
end

class IntegerNode < Node
  def initialize(value)
    @value = value
  end

  def eval
    @value
  end
end

class BinaryOpNode < Node
  def initialize(left, op, right)
    @left = left
    @op = op
    @right = right
  end

  def eval
    left_val = @left.eval
    right_val = @right.eval

    left_val.send(@op.to_sym, right_val)
  end
end


class Parser
  def initialize(tokens)
    @tokens = tokens
    @current_index = 0
  end

  def parse
  end

  private
end