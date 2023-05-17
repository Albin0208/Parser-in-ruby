#
# All the hash validation helper functions for the parser
#
module HashValidation
  private

  # Determines whether a given key is present in a list of keys.
  #
  # @param key [StringLiteral, SymbolLiteral] the key to search for
  # @param keys [Array<StringLiteral, SymbolLiteral>] the list of keys to search
  # @return [Boolean] true if the key is present in the list of keys, false otherwise
  def key_in_hash?(key, keys)
    return false unless key.is_a?(Nodes::StringLiteral)

    keys.each() { |k|
      return true if k.value == key.value
    }
    return false
  end

  #
  # Parses the hash_type specifier
  #
  # @return [String & String] The key and value types
  #
  def parse_hash_type_specifier
    # expect(Utilities::TokenType::HASH)

    hash_type = expect(Utilities::TokenType::HASH_TYPE).value.to_s

    hash_type = hash_type.gsub(/[<>\s]|(Hash)/, '').split(',')
    hash_type = parse_nested_hash(hash_type)
    value_type = hash_type[1]
    if value_type.is_a?(Array)
      pretty_type = ''
      flatt_type = value_type.flatten
      flatt_type.flatten.each_with_index() { |type, index| 
        pretty_type << if index < flatt_type.flatten.length - 1
                         "Hash<#{type},"
                       else
                         type.to_s
                       end
      }
      pretty_type << '>' * (flatt_type.flatten.length - 1)
      value_type = pretty_type
    end

    return hash_type[0], value_type.to_sym
  end

  # Recursively parses a hash type specifier, splitting it into an array of nested key types.
  # @param hash_type [Array] the hash type specifier to parse
  # @return [Symbol, Array] the parsed hash type specifier
  def parse_nested_hash(hash_type)
    return hash_type.first.to_sym if hash_type.length == 1

    return [hash_type.shift.to_sym, parse_nested_hash(hash_type)]
  end
end