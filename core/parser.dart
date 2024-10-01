import 'lexer.dart';

class Parser {
  Lexer lexer;
  late Token currentToken;
  Map<String, dynamic> symbolMap = {};

  Parser(this.lexer) {
    currentToken = lexer.getNextToken();
  }

  void eat(TokenType type) {
    if (currentToken.type == type) {
      currentToken = lexer.getNextToken();
    } else {
      throw Exception(
          'Syntax Error: Expected ${type.toString()}, got ${currentToken.type.toString()}');
    }
  }

  void parsePrintStatement() {
    eat(TokenType.print);
    var result = expr();
    print(result);
    eat(TokenType.semicolon);
  }

  dynamic expr() {
    Token token = currentToken;

    // Handle string literals
    if (currentToken.type == TokenType.string) {
      String value = currentToken.value;
      eat(TokenType.string); // Consume the string token
      return value;
    }

    // Handle numbers or variables (identifiers)
    if (currentToken.type == TokenType.number || currentToken.type == TokenType.identifier) {
      // If it's an identifier, resolve it from the symbolMap
      if (currentToken.type == TokenType.identifier) {
        String varName = currentToken.value;
        eat(TokenType.identifier); // Consume the identifier token

        if (!symbolMap.containsKey(varName)) {
          throw Exception('Variable $varName is not defined');
        }

        dynamic varValue = symbolMap[varName];
        if (varValue is int) {
          token = Token(TokenType.number, varValue.toString());
        } else if (varValue is String) {
          return varValue; // Return the string variable
        } else {
          throw Exception('Unsupported variable type for arithmetic');
        }
      } else {
        eat(TokenType.number); // Consume the number token if it's not an identifier
      }

      int result = int.parse(token.value); // Convert token to int

      // Handle arithmetic operations (+, -, *, /)
      while (currentToken.type == TokenType.plus ||
          currentToken.type == TokenType.minus ||
          currentToken.type == TokenType.star ||
          currentToken.type == TokenType.slash) {
        Token operator = currentToken;
        eat(operator.type); // Consume the operator token

        Token nextToken = currentToken;

        // If next token is an identifier, resolve it
        if (nextToken.type == TokenType.identifier) {
          String nextVar = currentToken.value;
          eat(TokenType.identifier); // Consume the identifier

          if (!symbolMap.containsKey(nextVar)) {
            throw Exception('Variable $nextVar is not defined');
          }

          dynamic varValue = symbolMap[nextVar];
          if (varValue is int) {
            nextToken = Token(TokenType.number, varValue.toString());
          } else {
            throw Exception('Only numbers are allowed for arithmetic operations');
          }
        } else {
          eat(TokenType.number); // Consume the number
        }

        int nextValue = int.parse(nextToken.value);

        switch (operator.type) {
          case TokenType.plus:
            result += nextValue;
            break;
          case TokenType.minus:
            result -= nextValue;
            break;
          case TokenType.star:
            result *= nextValue;
            break;
          case TokenType.slash:
            if (nextValue == 0) throw Exception('Division by zero');
            result ~/= nextValue;
            break;
          default:
            throw Exception('Unexpected operator');
        }
      }

      return result;
    }

    throw Exception('Syntax Error: Expected a number, variable, or string');
  }

  void parseVarStatement() {
    eat(TokenType.variable); // Consume 'var'

    // print('After var, currentToken: ${currentToken.type}, ${currentToken.value}');

    // Expect an identifier (variable name)
    if (currentToken.type != TokenType.identifier) {
      throw Exception('Syntax Error: Expected variable name after "var"');
    }

    String varName = currentToken.value;
    eat(TokenType.identifier); // Consume the variable name

    // print('After identifier, currentToken: ${currentToken.type}, ${currentToken.value}');

    // Expect an '=' token
    if (currentToken.type != TokenType.equals) {
      throw Exception('Syntax Error: Expected "=" after variable name');
    }
    eat(TokenType.equals); // Consume '='

    // print('After "=", currentToken: ${currentToken.type}, ${currentToken.value}');

    // Parse the expression on the right-hand side
    dynamic varValue = expr();

    // print('Parsed value for $varName: $varValue');

    symbolMap[varName] = varValue;

    // Expect a semicolon to end the statement
    if (currentToken.type != TokenType.semicolon) {
      throw Exception('Syntax Error: Expected ";" at the end of the variable declaration');
    }
    eat(TokenType.semicolon); // Consume the semicolon
    // print('After ";", currentToken: ${currentToken.type}, ${currentToken.value}');
  }

  void parse() {
    while (currentToken.type != TokenType.eof) {
      if (currentToken.type == TokenType.print) {
        parsePrintStatement();
      } else if (currentToken.type == TokenType.variable) {
        parseVarStatement();
      } else {
        throw Exception('Syntax Error: Unexpected token ${currentToken.value}');
      }
    }
  }
}
