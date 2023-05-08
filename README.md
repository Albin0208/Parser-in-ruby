# Parser-in-ruby
A simple parser and lexer implementation in Ruby. This project was created for educational purposes as part of the TDP019 course in Innovative Programming at Linköping University. Please note that this parser is a hobby project and may contain bugs and other issues.

## Installation
To run this project, you'll need to have Ruby installed on your system. If you don't have Ruby, you can download it from the official website: https://www.ruby-lang.org/en/downloads/.

Once you have Ruby installed, you can clone this repository using the following command:

```bash
git clone https://gitlab.liu.se/albda746/tdp019.git
```

## Usage
To use the parser, navigate to the root directory of the project and run main.rb file. The parser can be used to parse a file or as a REPL.

### Run on file
To run the parser on a file, use the following command:

```bash
ruby main.rb file_name
```

### Run as REPL
To run the parser as a REPL, execute the following command:

```bash
ruby main.rb
```

### Debug mode

***Important***: Debug mode is only intended for developing the parser and not for using the language.

The parser can be run in debug mode, which prints additional information to the console. To run the parser in debug mode, pass the ``-debug`` flag as follows:

```bash
ruby main.rb -debug
```

This can also be done when running on a file. The command would then look like this:

```bash
ruby main.rb file_name -debug
```

## Generating documentations
To generate documentation for the project, ``rake`` and ``yard`` has to be installed.
If you don't have ``rake``, you can run the following command in your terminal:

```bash
gem install rake
```

To install ``yard``, run the following command in your terminal:

```bash
gem install yard
```

To generate the documentation for the language part use execute the following command:

```bash
rake doc
```


To generate the documentation for the parser, execute the following command:

***Important***: the parser documentation is only intended for developing the parser.

```bash
rake parser_doc
```

## Running unit tests

***Important***: The test are only intended to be used if developing the parser and has no effect on how your code in the language is working.

To run the unit tests, you'll need to have ``rake`` installed on your system. If you don't have ``rake``, you can run the following command in your terminal:

```bash
gem install rake
```

To run the unit tests, execute the following command:

```bash
rake test
```

***Note***: The interpreter test assumes that all the parser test and lexer test works correctly since it uses those for its tests

## License
This project is released under the MIT License. See the [LICENSE](https://github.com/Albin0208/Parser-in-ruby/blob/master/LICENSE) file for details.