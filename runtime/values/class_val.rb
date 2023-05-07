require_relative 'runtime_val'

module Runtime
	module Values
		class ClassVal < RunTimeVal
			attr_reader :class_instance

			def initialize(value, class_instance)
				super(value, value.to_sym)
				@class_instance = class_instance
			end

			def !=(other)
				Values::BooleanVal.new(!(other == self))
			end

			def ==(other)
				return Values::BooleanVal.new(true) if other.object_id.equal?(self.object_id)

				return Values::BooleanVal.new(false)
			end

			def copy
				Values::ClassVal.new(@value, @class_instance.clone)
			end
		end
	end
end