# Parser-in-ruby
A simple parser and lexer implementation in Ruby. This project was created for educational purposes as part of the TDP019 course in Innovative Programming at Linköping University. Please note that this parser is a hobby project and may contain bugs and other issues.

## Installation
To run this project, you'll need to have Ruby installed on your system. If you don't have Ruby, you can download it from the official website: https://www.ruby-lang.org/en/downloads/.

Once you have Ruby installed, you can clone this repository using the following command:

```bash
git clone https://github.com/Albin0208/Parser-in-ruby.git
```

## Usage

### Running the parser
To run the parser, simply execute the following command in your terminal:


```bash
ruby main.rb
```

### Running the parser in debug mode
You can also run the parser in debug mode, which will print additional information to the console. To do this, simply pass the ``-debug`` flag when running the parser, like so:

```bash
ruby main.rb - debug
```

## Unit tests
To run the test, you'll need to have Rake installed on your system. If you don't have Rake you can run the following command int your terminal:

```bash
gem install rake
```

### Running the tests
To run the unit test, simply execute the following command in your terminal:

```bash
rake test
```

***Note***: The interpreter test assuemses that all the parser test and lexer test works correcly since it uses those for its tests

## License
This project is released under the MIT License. See the [LICENSE](https://github.com/Albin0208/Parser-in-ruby/blob/master/LICENSE) file for details.