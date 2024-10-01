import 'lexer.dart';

class Parser {
  Lexer lexer;
  late Token currentToken;
  Map<String, dynamic> symbolMap = {};
  Map<String, dynamic> functionsMap = {};

  static const int MAX_RECURSION_DEPTH = 1000;
  int recursionDepth = 0;

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

  dynamic expr([Map<String, dynamic>? localSymbolMap]) {
    Token token = currentToken;

    // Handle string literals
    if (currentToken.type == TokenType.string) {
      String value = currentToken.value;
      eat(TokenType.string); // Consume the string token
      return value;
    }

    // Handle numbers or variables (identifiers)
    if (currentToken.type == TokenType.number || currentToken.type == TokenType.identifier) {
      if (currentToken.type == TokenType.identifier) {
        String varName = currentToken.value;
        eat(TokenType.identifier); // Consume the identifier token

        // Check the local symbol map first, then the global symbol map
        dynamic varValue;
        if (localSymbolMap != null && localSymbolMap.containsKey(varName)) {
          varValue = localSymbolMap[varName];
        } else if (symbolMap.containsKey(varName)) {
          varValue = symbolMap[varName];
        } else {
          throw Exception('Variable $varName is not defined');
        }

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

          dynamic varValue;
          if (localSymbolMap != null && localSymbolMap.containsKey(nextVar)) {
            varValue = localSymbolMap[nextVar];
          } else if (symbolMap.containsKey(nextVar)) {
            varValue = symbolMap[nextVar];
          } else {
            throw Exception('Variable $nextVar is not defined');
          }

          if (varValue is int) {
            nextToken = Token(TokenType.number, varValue.toString());
          } else {
            throw Exception('Only numbers are allowed for arithmetic operations');
          }
        } else {
          eat(TokenType.number); // Consume the number
        }

        int nextValue = int.parse(nextToken.value);

        result = parseBinaryOperation(result, operator, nextValue);
      }

      return result;
    }

    throw Exception('Syntax Error: Expected a number, variable, or string');
  }

  int parseBinaryOperation(int left, Token operatorToken, int right) {
    switch (operatorToken.type) {
      case TokenType.plus:
        return left + right;
      case TokenType.minus:
        return left - right;
      case TokenType.star:
        return left * right;
      case TokenType.slash:
        if (right == 0) throw Exception('Division by zero');
        return left ~/ right; // Integer division
      default:
        throw Exception('Unexpected operator ${operatorToken.value}');
    }
  }

  void parseVarStatement() {
    eat(TokenType.variable); // Consume 'var'

    if (currentToken.type != TokenType.identifier) {
      throw Exception('Syntax Error: Expected variable name after "var"');
    }

    String varName = currentToken.value;
    eat(TokenType.identifier); // Consume the variable name

    if (currentToken.type != TokenType.equals) {
      throw Exception('Syntax Error: Expected "=" after variable name');
    }
    eat(TokenType.equals); // Consume '='

    dynamic varValue = expr();

    symbolMap[varName] = varValue;

    if (currentToken.type != TokenType.semicolon) {
      throw Exception('Syntax Error: Expected ";" at the end of the variable declaration');
    }
    eat(TokenType.semicolon); // Consume the semicolon
  }

  void parseFunction() {
    eat(TokenType.function); // Consume 'func'

    if (currentToken.type != TokenType.identifier) {
      throw Exception('Syntax Error: Expected function name after "func"');
    }

    String funcName = currentToken.value;
    eat(TokenType.identifier); // Consume the function name

    if (currentToken.type != TokenType.equals) {
      throw Exception('Syntax Error: Expected "=" after function name');
    }
    eat(TokenType.equals); // Consume '='

    // Parse function parameters
    List<String> params = [];
    if (currentToken.type == TokenType.lparen) {
      eat(TokenType.lparen); // Consume '('

      while (currentToken.type != TokenType.rparen) {
        if (currentToken.type == TokenType.identifier) {
          params.add(currentToken.value);
          eat(TokenType.identifier); // Consume the parameter name
        }
        if (currentToken.type == TokenType.comma) {
          eat(TokenType.comma); // Consume the comma
        }
      }
      eat(TokenType.rparen); // Consume ')'
    }

    if (currentToken.type != TokenType.lbrace) {
      throw Exception('Syntax Error: Expected "{" to start function body');
    }
    eat(TokenType.lbrace); // Consume '{'

    // Parse the function body (do NOT execute it)
    List<Map<String, dynamic>> functionBody = [];

    while (currentToken.type != TokenType.rbrace) {
      if (currentToken.type == TokenType.print) {
        eat(TokenType.print); // Consume the 'print' token
        dynamic value = parseExpression(); // Parse the arithmetic expression
        functionBody.add({'type': 'print', 'value': value});
        eat(TokenType.semicolon); // Consume the semicolon
      } else if (currentToken.type == TokenType.variable) {
        String varName = currentToken.value;
        eat(TokenType.variable); // Consume 'var'
        eat(TokenType.identifier); // Consume the identifier (variable name)
        eat(TokenType.equals); // Consume '='
        dynamic varValue = parseExpression(); // Parse the arithmetic expression
        functionBody.add({'type': 'var', 'name': varName, 'value': varValue});
        eat(TokenType.semicolon); // Consume the semicolon
      } else {
        throw Exception('Syntax Error: Unexpected token ${currentToken.value} in function body');
      }
    }
    eat(TokenType.rbrace); // Consume '}'

    // Store the function in the functionsMap for later use
    functionsMap[funcName] = {
      'params': params,
      'body': functionBody,
    };

    if (currentToken.type != TokenType.semicolon) {
      throw Exception('Syntax Error: Expected ";" after function declaration');
    }
    eat(TokenType.semicolon); // Consume ';'
  }

  dynamic parseExpression() {
    dynamic left = parseTerm();

    while (currentToken.type == TokenType.plus || currentToken.type == TokenType.minus) {
      String operator = currentToken.value;
      eat(currentToken.type); // Consume the operator
      dynamic right = parseTerm();

      if (operator == '+') {
        left = left + right;
      } else if (operator == '-') {
        left = left - right;
      }
    }

    return left;
  }

  dynamic parseTerm() {
    dynamic left = parseFactor();

    while (currentToken.type == TokenType.star || currentToken.type == TokenType.slash) {
      String operator = currentToken.value;
      eat(currentToken.type); // Consume the operator
      dynamic right = parseFactor();

      if (operator == '*') {
        left = left * right;
      } else if (operator == '/') {
        left = left / right;
      }
    }

    return left;
  }

  dynamic parseFactor() {
    // This can be either a number or an identifier (like num1, num2)
    if (currentToken.type == TokenType.number) {
      dynamic value = currentToken.value;
      eat(TokenType.number); // Consume the number
      return value;
    } else if (currentToken.type == TokenType.identifier) {
      String varName = currentToken.value;
      eat(TokenType.identifier); // Consume the identifier
      return varName; // Return the variable (will be resolved later)
    } else {
      throw Exception('Syntax Error: Unexpected token in expression');
    }
  }

  dynamic callFunction(String funcName, List<dynamic> args) {
    if (recursionDepth >= MAX_RECURSION_DEPTH) {
      throw Exception('Maximum recursion depth exceeded');
    }

    recursionDepth++;
    try {
      if (!functionsMap.containsKey(funcName)) {
        throw Exception('Function $funcName is not defined');
      }

      var functionData = functionsMap[funcName];
      List<String> params = functionData['params'];
      List<dynamic> body = functionData['body'];

      if (args.length != params.length) {
        throw Exception('Argument count mismatch for function $funcName');
      }

      // Create a local symbol map for the function
      Map<String, dynamic> localSymbolMap = {};

      // Map the passed arguments to the function's parameters
      for (int i = 0; i < params.length; i++) {
        localSymbolMap[params[i]] = args[i];
      }

      print('Calling function $funcName with args: $args');

      // Execute the function body
      for (var statement in body) {
        switch (statement['type']) {
          case 'print':
            dynamic valueToPrint = statement['value'];

            // Resolve the value if it's an identifier (like 'name')
            if (localSymbolMap.containsKey(valueToPrint)) {
              valueToPrint = localSymbolMap[valueToPrint];
            }

            print(valueToPrint);
            break;

          case 'var':
            String varName = statement['name'];
            dynamic varValue = statement['value'];

            // If varValue is a reference to a parameter, resolve it from the localSymbolMap
            if (varValue is String && localSymbolMap.containsKey(varValue)) {
              varValue = localSymbolMap[varValue];
            }

            localSymbolMap[varName] = varValue;
            break;

          default:
            throw Exception('Unexpected statement type ${statement['type']}');
        }
      }

      return null; // Return null if the function has no explicit return
    } finally {
      recursionDepth--;
    }
  }

  void parse() {
    while (currentToken.type != TokenType.eof) {
      if (currentToken.type == TokenType.print) {
        parsePrintStatement();
      } else if (currentToken.type == TokenType.variable) {
        parseVarStatement();
      } else if (currentToken.type == TokenType.function) {
        parseFunction();
      } else if (currentToken.type == TokenType.identifier) {
        String identifier = currentToken.value;
        eat(TokenType.identifier);

        // Check if this is a function call
        if (currentToken.type == TokenType.lparen) {
          // It's a function call
          eat(TokenType.lparen); // Consume '('
          List<dynamic> args = [];

          // Collect arguments
          if (currentToken.type != TokenType.rparen) {
            args.add(expr());
            while (currentToken.type == TokenType.comma) {
              eat(TokenType.comma); // Consume ','
              args.add(expr());
            }
          }

          eat(TokenType.rparen); // Consume ')'
          eat(TokenType.semicolon); // Consume ';'

          // Call the function
          callFunction(identifier, args);
        } else {
          throw Exception('Syntax Error: Unexpected token $identifier');
        }
      } else {
        throw Exception('Syntax Error: Unexpected token ${currentToken.value}');
      }
    }
  }
}
