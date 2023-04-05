# Features to add 

- [x] Strings
    - [x] Allow escaping a string
- [x] Elsif
- [x] Add new env to if statements
- [ ] Arrays
    - [ ] ArrayLiteral
    - [ ] Array accessor
- [ ] Loops
    - [ ] While loop
    - [ ] For loop
    - [ ] Loop over containers
- [ ] Hashmap
    - [ ] HashLiteral
    - [ ] Hash accessor
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
- [ ] Classes
    - [ ] Inheritance

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
- [ ] Test that new environments are correct and that it can access vars int parents but not in other scopes

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

- [ ] While loop: i = 1; while i <= 5 do puts i; i += 1; end
- [ ] For loop: for i in 1..5 do puts i end
### Test function definition and invocation:

- [ ] Function definition: func int add(a,b) { return a + b }
- [ ] Function invocation: add(2,3)
### Test arrays:

- [ ] Array creation: int[] arr = [1, 2, 3]
- [ ] Array indexing: arr[1]
- [ ] Array length: arr.length
- [ ] Array iteration: arr.each {|a| puts a}
### Test hashes:

- [ ] Hash creation: Hash<string, int> h = { "one" => 1, "two" => 2 }
- [ ] Hash retrieval: h["one"]
- [ ] Hash iteration: h.each {|key, value| puts "#{key} is #{value}"}
### Test exceptions:
- [ ] Zero division error: 10/0