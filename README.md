
# Simple Interpreter with Dart

This repository contains a basic interpreter written in Dart. It includes a lexer, parser, and interpreter capable of handling simple arithmetic expressions, variable declarations, and print statements.

## Features

- Tokenizes input using a lexer.
- Parses expressions, including:
  - Arithmetic operations: `+`, `-`, `*`, `/`
  - String literals
  - Variable declarations (`var` keyword)
  - Print statements (`print` keyword)
- Supports basic syntax validation.

## Usage

### Running the Interpreter

The interpreter expects a `.dse` file as input. You can run the interpreter using the following command:

```bash
dart run lib/main.dart
```

Place your `.dse` file in the appropriate path (as defined in `Paths.appPath`) and ensure the file has valid syntax. The interpreter will read the file, tokenize the content, parse the tokens, and execute the resulting commands.

### Example Code (`app.dse`)

```plaintext
var x = 10;
var y = 20;
print x + y;
print "Hello, World!";
```

### Sample Output

```plaintext
Running interpreter for file: app.dse
30
Hello, World!
finished in 0.004s
```

## Project Structure

- **core/lexer.dart**: Contains the `Lexer` class responsible for tokenizing the source code.
- **core/parser.dart**: Contains the `Parser` class, which handles the parsing and interpreting of tokens.
- **lib/main.dart**: Main entry point for running the interpreter.
- **constants/path.dart**: Provides file path constants.

## Supported Tokens

| Token       | Description                  |
| ----------- | ---------------------------- |
| `number`    | Integer literals              |
| `plus`      | `+` operator                  |
| `minus`     | `-` operator                  |
| `star`      | `*` operator                  |
| `slash`     | `/` operator                  |
| `print`     | Print statement               |
| `identifier`| Variable names                |
| `eof`       | End of file                   |
| `qmark`     | Question mark (not used)      |
| `string`    | String literals               |
| `variable`  | `var` keyword                 |
| `equals`    | `=` assignment operator       |
| `semicolon` | `;` statement terminator      |
| `comment`   | Comments (`//` style)         |

## Requirements

- Dart SDK

Install the Dart SDK by following the instructions at [https://dart.dev/get-dart](https://dart.dev/get-dart).

## How to Contribute

Feel free to fork this repository and submit pull requests. Contributions, such as improvements to the interpreter, additional features, or bug fixes, are welcome.

### How to Run Tests

There are currently no automated tests, but you can test the interpreter by writing `.dse` files and running them with the interpreter.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Repository

The repository is hosted on GitHub. Clone it or explore the code [here](https://github.com/MultiX0/simple-Interpreter-with-dart.git).