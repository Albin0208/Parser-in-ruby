# Features to add 

- [x] Strings
    - [x] Allow escaping a string
- [x] Elsif
- [x] Add new env to if statements
- [ ] Arrays
    - [ ] ArrayLiteral
    - [ ] Array accessor
- [ ] Loops
    - [x] While loop
    - [x] For loop
        - [x] Fix so not every stmt are ok to have in the expr part
    - [ ] Loop over containers
    - [x] Break statement to exit early
    - [x] Continue statement to continue next iteration instead
- [x] Native functions, like print() and so on
- [x] Hashmap
    - [x] HashLiteral
    - [x] Hash accessor
    - [x] Hashes has to be type specified ( Hash<int, int> a = Hash<string, int>{ "hej" = 3.0, "hejs" = test()} )
- [x] Functions
    - [x] Function Declaration
    - [x] Function calls
    - [x] Add void type for functions
    - [x] Return Statments
        - [x] Checks for type so correct when returning
    - [x] Parse params
    - [x] Evaluate params
    - [x] Setup new env for a function body
    - [x] Not allowed to create a function in another function
    - [ ] Lambda functions?
- [x] Don't allow returns outside functions
- [x] Fixa så att continue och break inte finns utanför loopar
- [x] Property access for objects (Probably best to implement classes first)
- [ ] Classes
    - [ ] Inheritance

# Fix wonky stuff
- [ ] Fix problem when a identifier such as a class is printed it show the whole class node.
- [ ] Fix so when an hash i printed it prints the value if it exist
- [ ] Fix so a hash of hashes are ok

# Tests
## Lexer tests
- [x] Test string
    - [x] Test with "" and ''
    - [x] Test that error raises when string has missmatched quotes
    - [x] Test that we can escape chars with \
- [x] Test Elsif

## Parser tests
- [x] Test string
    - [x] Test that string parser correctly
- [x] Test Elsif

## Interpreter tests
- [x] Test that string evaluates correctly
- [x] Test Elsif
- [ ] Test that new environments are correct and that it can access vars in parents but not in other scopes

### Test arithmetic operations:
- [x] Addition: 2+3
- [x] Subtraction: 5-3
- [x] Multiplication: 2*4
- [x] Division: 10/2
- [x] Modulo: 10%3
### Test variable assignment and retrieval:

- [x] Assignment: x = 5
- [x] Retrieval: x
### Test conditional statements:
- [x] If statement: if 5 > 3 { 3 + 3}
- [x] If-else statement: if 5 < 3 { 5 + 3} else { 5 - 3}
### Test loops:

- [x] While loop: i = 1; while i <= 5 do puts i; i += 1; end
- [x] For loop: for i in 1..5 do puts i end
### Test function definition and invocation:

- [x] Function definition: func int add(a,b) { return a + b }
- [x] Function invocation: add(2,3)
### Test arrays:

- [ ] Array creation: int[] arr = [1, 2, 3]
- [ ] Array indexing: arr[1]
- [ ] Array length: arr.length
- [ ] Array iteration: arr.each {|a| puts a}
### Test hashes:

- [x] Hash creation: Hash<string, int> h = Hash<string, int>{ "one" = 1, "two" = 2 }
- [x] Hash retrieval: h["one"]
- [x] Hash retrieval with func calls h[key_gen()]
- [ ] Hash iteration: h.each {|key, value| puts "#{key} is #{value}"}
- [x] Invalid hashes raises error
- [x] Missmatched types raises errors
### Test exceptions:
- [ ] Zero division error: 10/0

### TEST
- [x] Ensure return outside of function raises error
- [x] Test break statements
- [x] Test Continue statements