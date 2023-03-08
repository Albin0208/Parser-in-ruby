# Tests
## Lexer tests

## Parser tests

## Interpreter tests

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
- [ ] If statement: if 5 > 3 then puts "5 is greater than 3" end
- [ ] If-else statement: if 5 < 3 then puts "5 is less than 3" else puts "5 is not less than 3" end
### Test loops:

- [ ] While loop: i = 1; while i <= 5 do puts i; i += 1; end
- [ ] For loop: for i in 1..5 do puts i end
### Test function definition and invocation:

- [ ] Function definition: def add(a,b) a + b end
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