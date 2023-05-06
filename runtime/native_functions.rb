class NativeFunctions
	FUNCTIONS = ['print']

	def self.dispatch(name, args)
		case name
		when 'print'
			puts if args.empty?
			args.each() { |arg| puts arg }
		end
	end
end