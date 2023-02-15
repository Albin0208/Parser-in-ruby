require_relative 'Token'
require_relative 'BinaryOperations'
require_relative 'Errors'

class Lexer
    TOKEN_TYPES = {
        "integer" => /\d/,
        "operators" => /[\+\-\*\/]/,
        "lparen" => /\(/,
        "rparen" =>  /\)/,
    }

    def initialize(string)
        @string = string.rstrip # Remove any trailing whitespace
        @sub_line = ""
        @position = 0
        @line = 1
        @column = 1

        @tokens = []
    end 

    def next_token()
        return nil if @position >= @string.length

        @sub_line = @string[0..@string.length].match(/^\s*.*$/)

        # Skip whitespace
        while @string[@position] =~ /\s/
            # We find a new line update the line and column value
            if @string[@position] == "\n"
                @line += 1
                @column = 1
            else
                @column += 1
            end
           @position += 1
        end

        case @string[@position]
        when TOKEN_TYPES["integer"]
          # Parse integer
          start_pos = @position
          # Eat all the integers
          while @position < @string.length && @string[@position] =~ TOKEN_TYPES["integer"]
            @position += 1
            
          end
		  token = Token.new("integer", @string[start_pos..@position-1].to_i, @line, @column)
		  @column += @position - start_pos # Step forward the column the length of the number
          return token
    
        when TOKEN_TYPES["operators"]
          # Parse operator
          token = Token.new("operator", @string[@position], @line, @column)
          @position += 1
          @column += 1
          return token
    
        when TOKEN_TYPES["lparen"]
          # Create left paren token
          token = Token.new("lparen", @string[@position], @line, @column)
          @position += 1
          @column += 1
          return token
    
        when TOKEN_TYPES["rparen"]
          # Create right paren token
          token = Token.new("rparen", @string[@position], @line, @column)
          @position += 1
          @column += 1
          return token
          else
            raise MySyntaxError, "Invalid character or unexpected token at line #{@line}, column #{@column} in #{@sub_line}"
          end   
    end

    def tokenize
        while (token = next_token)
            @tokens << token
        end
        return @tokens
    end
end

# input = "1 + 2 * 3 - (4 / 2)
# -45"

# input = gets.chomp()
# lexer = Lexer.new(input)
# puts lexer.tokenize.map(&:to_s).inspect