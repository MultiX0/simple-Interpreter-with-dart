import '../core/parser.dart';
import '../core/lexer.dart';
import 'dart:io';
import '../constants/path.dart';

void runInterpreter(String sourceCode) {
  Stopwatch stopwatch = Stopwatch()..start();

  Lexer lexer = Lexer(sourceCode);
  Parser parser = Parser(lexer);

  parser.parse();
  stopwatch.stop();
  print("finished in ${stopwatch.elapsed.inSeconds}.${stopwatch.elapsed.inMilliseconds}s");
}

void main() async {
  final path = Paths.appPath;
  String filePath = '$path/app.dse';

  if (filePath.endsWith('.dse')) {
    try {
      String fileContent = await File(filePath).readAsString();
      print("Running interpreter for file: ${filePath.split('/').last}");
      runInterpreter(fileContent);
    } catch (e) {
      print("Error reading the file: $e");
    }
  } else {
    print("Error: Invalid file extension. Please provide a .dse file.");
  }
}
