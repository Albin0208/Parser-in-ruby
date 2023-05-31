# Cobra
Cobra is a programming language that takes inspiration from C++ and Python.

## Introduction
Cobra is designed to combine the best features of both C++ and Python, offering a powerful and expressive programming language. It aims to provide a familiar syntax and rich set of features for developers, while also promoting code readability and maintainability.


## Table of Contents
- [Description](#description)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Getting started](#getting-started)
  - [Run on File](#run-on-file)
  - [Run as REPL](#run-as-repl)
  - [Debug Mode](#debug-mode)
- [Generating Documentations](#generating-documentations)
- [Running Unit Tests](#running-unit-tests)
- [Examples](#examples)
- [Documentation](#documentation)
- [License](#license)

## Description
This project provides a parser, lexer, and interpreter implementation in Ruby, allowing you to parse and execute Cobra code. Whether you want to parse files or use it as a REPL (Read-Eval-Print Loop) for interactive parsing, Cobra has got you covered.

Please note that Cobra is a hobby project created for educational purposes as part of the TDP019 course in Innovative Programming at Linköping University. As such, it may contain bugs and other issues.

## Requirements

To run this project, you'll need to have Ruby installed on your system. If you don't have Ruby, you can download it from the official website: [https://www.ruby-lang.org/en/downloads/](https://www.ruby-lang.org/en/downloads/).

## Installation
To install the project, clone this repository using the following command:

```properties
git clone https://github.com/Albin0208/Parser-in-ruby.git
```

## Usage
To use the parser, navigate to the root directory of the project and run the main.rb file. The parser can be used to parse a file or as a REPL (Read-Eval-Print Loop) for interactive parsing.

### Getting started
To get started with Cobra, follow these steps:
1. Clone the repository:
   ```properties
   git clone https://github.com/Albin0208/Parser-in-ruby.git
   ```
2. Navigate to the project directory:
   ```properties
   cd Parser-in-ruby
   ```
3. Run the `main.rb` file:
   ```properties
   ruby main.rb
   ```
   This will start the Cobra REPL, where you can enter and execute Cobra code interactively.
4. Alternatively, you can run the parser on a Cobra file:
   ```properties
   ruby main.rb <file_name>.cobra
   ```
   Replace `<file_name>` with the name of the Cobra file you want to parse.


### Run on file
To run the parser on a file, use the following command:

```properties
ruby main.rb <file_name>.cobra
```

Replace <file_name> with the name of the file you want to parse.

### Run as REPL
To run the parser as a REPL, execute the following command:

```properties
ruby main.rb
```

### Debug mode

**Important**: Debug mode is intended for developing the parser and should not be used when running Cobra code in production.

The parser can be run in debug mode, which prints additional information to the console. To run the parser in debug mode, pass the ``-debug`` flag as follows:

```properties
ruby main.rb -debug
```

This can also be done when running on a file. The command would then look like this:

```properties
ruby main.rb <file_name>.cobra -debug
```

Debug mode is useful for debugging and understanding the inner workings of the parser, but it may produce verbose output that is not relevant for regular usage. Therefore, it's recommended to use debug mode only during development and debugging phases.

## Generating documentations
To generate documentation for the project, ``rake`` and ``yard`` has to be installed.

If you don't have ``rake``, you can run the following command in your terminal:

```properties
gem install rake
```

To install ``yard``, run the following command in your terminal:

```properties
gem install yard
```

To generate the documentation for the language part use execute the following command:

```properties
rake doc
```


To generate the documentation for the parser, execute the following command:

***Important***: the parser documentation is only intended for developing the parser.

```properties
rake parser_doc
```

## Running unit tests

***Important***: The test are only intended to be used if developing the parser and has no effect on how your code in the language is working.

To run the unit tests, you'll need to have ``rake`` installed on your system. If you don't have ``rake``, you can run the following command in your terminal:

```properties
gem install rake
```

To run the unit tests, execute the following command:

```properties
rake test
```

***Note***: The interpreter test assumes that all the parser test and lexer test works correctly since it uses those for its tests

## Examples
Here are some examples of Cobra code:

1. Hello World:
    ````python
    print('Hello World') #=> Hello World
    ````
2. Fibbonacci Series:
    ```python
    func int fibbonacci(int n) {
        if n <= 1 {
            return n
        }
        return fibbonacci(n - 1) + fibbonacci(n - 2)
    }

    print(fibbonacci(10)) #=> 55
    ```
3. Factorial:
    ````python
    func int factorial(int n) {
        if n == 0 {
            return 1
        }
        return n * factorial(n - 1)
    }
    print(factorial(5)) #=> 120
    ````

Feel free to explore and experiment with Cobra by creating your own programs!

## Documentation
More examples and detailed documentation can be found in the [Språkdokumentation](https://github.com/Albin0208/Parser-in-ruby/blob/master/documentation/spr%C3%A5kdokumentation/Cobra-Språkdokumentation.pdf) (Language Documentation). Please note that the documentation is written in Swedish and may not be fully updated to the latest features of Cobra.


For more examples and detailed information on how to use all the features in Cobra, you can generate the documentation. Refer to the [Generating Documentations](#generating-documentations) section for instructions on how to generate the documentation for the language part and the parser.

The generated documentation will provide comprehensive explanations and examples of Cobra's syntax, language features, and usage guidelines.

Feel free to explore the documentation to learn more about Cobra and its capabilities.

## License
This project is released under the MIT License. See the [LICENSE](https://github.com/Albin0208/Parser-in-ruby/blob/master/LICENSE) file for details.