module Runtime
	module Values
		class BooleanVal < RunTimeVal
			def initialize(value = true)
				super(value, :bool)
			end
		
			def !
				Values::BooleanVal.new(!@value)
			end
		
			def !=(other)
				Values::BooleanVal.new(@value != other.value)
			end
		
			def ==(other)
				Values::BooleanVal.new(@value == other.value)
			end
		end
	end
end