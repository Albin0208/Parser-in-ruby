require_relative 'stmt'

class ClassDeclaration < Stmt
	attr_reader :class_name, :member_variables, :member_functions
	attr_accessor :env

	def initialize(class_name, member_variables, member_functions)
		super(NODE_TYPES[:ClassDeclaration])
		@class_name = class_name
		@member_variables = member_variables
		@member_functions = member_functions
	end

	def to_s
		"Class name: #{@class_name}"
	end

  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * (indent + 2)} Name: #{@class_name}"
    puts "#{' ' * (indent + 2)} Variables:"
    @member_variables.each { |var| var.display_info(indent + 4) }
    puts "#{' ' * (indent + 2)} Functions:"
    @member_functions.each { |func| func.display_info(indent + 4) }
  end
end