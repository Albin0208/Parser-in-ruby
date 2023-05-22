module Runtime
	#
	# The class which contains all the Native functions in the program
	#
	class NativeFunctions
		FUNCTIONS = ['print']

		#
		# Dispatches the args to the called function
		#
		# @param [String] name The name of the function
		# @param [Array] args The list of all args passed to the function
		#
		def self.dispatch(name, args)
			case name
			when 'print'
				puts if args.empty?
				args.each() { |arg| puts arg.to_s.is_a?(String) ? arg.to_s : arg.to_s.value }
			end
		end
	end
end