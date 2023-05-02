require_relative 'stmt'

# Represents a class declaration in the AST, containing its name, member variables, and member functions.
class ClassDeclaration < Stmt
	attr_reader :class_name, :member_variables, :member_functions
	attr_accessor :env, :instance_env

	# Initializes a ClassDeclaration object with the given name, member variables, and member functions.
  # @param class_name [String] The name of the class.
  # @param member_variables [Array<VarDeclaration>] An array of member variable declarations in the class.
  # @param member_functions [Array<FuncDeclaration>] An array of member function declarations in the class.
  def initialize(class_name, member_variables, member_functions)
		super(NODE_TYPES[:ClassDeclaration])
		@class_name = class_name
		@member_variables = member_variables
		@member_functions = member_functions
  end

	def to_s
		"Class name: #{@class_name}"
	end

	# Displays information about the class declaration, including its name, member variables, and member functions.
  # @param indent [Integer] The indentation level for the displayed information.
  def display_info(indent = 0)
    puts "#{' ' * indent} #{self.class.name}"
    puts "#{' ' * (indent + 2)} Name: #{@class_name}"
    puts "#{' ' * (indent + 2)} Variables:"
    @member_variables.each { |var| var.display_info(indent + 4) }
    puts "#{' ' * (indent + 2)} Functions:"
    @member_functions.each { |func| func.display_info(indent + 4) }
  end

  # Creates a new instance of the class and initializes its instance variables and instance methods.
  # @param interpreter [Interpreter] The interpreter used to evaluate the initial values of instance variables.
  def create_instance(interpreter)
    @instance_env = Environment.new(@env.global_env)

    # Declare all instance variables
    @member_variables.each { |var|
      value = var.value ? interpreter.evaluate(var.value, @instance_env) : NullVal.new
      @instance_env.declare_var(var.identifier, value, var.value_type, var.constant)
    }

    # Declare all instance methods
    @member_functions.each { |method|
      @instance_env.declare_func(method.identifier, method.type_specifier, method.clone, @instance_env)
    }
  end
end