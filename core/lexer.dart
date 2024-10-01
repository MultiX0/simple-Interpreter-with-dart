import 'dart:core';

enum TokenType {
  number,
  plus,
  minus,
  star,
  slash,
  print,
  identifier,
  eof,
  qmark,
  string,
  variable,
  equals,
  semicolon,
  comment,
}

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);
}

class Lexer {
  String input;
  int position = 0;

  Lexer(this.input);

  Token getNextToken() {
    if (position >= input.length) return Token(TokenType.eof, '');

    String currentChar = input[position];

    if (currentChar == '/' && (position + 1) < input.length && input[position + 1] == '/') {
      position += 2;
      while (position < input.length && input[position] != '\n') {
        position++;
      }
      position++;
      return getNextToken();
    }

    if (RegExp(r'\d').hasMatch(currentChar)) {
      String number = '';
      while (position < input.length && RegExp(r'\d').hasMatch(input[position])) {
        number += input[position++];
      }
      return Token(TokenType.number, number);
    }

    if (currentChar == '+') return Token(TokenType.plus, input[position++]);
    if (currentChar == '-') return Token(TokenType.minus, input[position++]);
    if (currentChar == '*') return Token(TokenType.star, input[position++]);
    if (currentChar == '/') return Token(TokenType.slash, input[position++]);

    if (currentChar == '=') return Token(TokenType.equals, input[position++]);

    if (currentChar == '"') {
      position++;
      StringBuffer stringBuffer = StringBuffer();

      while (position < input.length && input[position] != '"') {
        stringBuffer.write(input[position]);
        position++;
      }

      if (position < input.length && input[position] == '"') {
        position++;
        return Token(TokenType.string, stringBuffer.toString());
      } else {
        throw Exception('Unterminated string literal');
      }
    }

    if (currentChar.trim().isEmpty) {
      position++;
      return getNextToken();
    }

    if (currentChar == ';') {
      position++;
      return Token(TokenType.semicolon, ';');
    }

    // Handle identifiers and keywords
    if (RegExp(r'[a-zA-Z]').hasMatch(currentChar)) {
      String identifier = '';

      // Identifiers can start with a letter, followed by letters or digits
      while (position < input.length && RegExp(r'[a-zA-Z0-9]').hasMatch(input[position])) {
        identifier += input[position++];
      }

      if (identifier == 'print') return Token(TokenType.print, 'print');
      if (identifier == 'var') return Token(TokenType.variable, 'var');

      return Token(TokenType.identifier, identifier);
    }

    throw Exception('Unexpected character: $currentChar');
  }
}
