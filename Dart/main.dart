import 'dart:io';
import 'package:antlr4/antlr4.dart';
import 'package:args/args.dart';
import 'DartLexer.dart';
import 'DartParser.dart';

import 'DartParserBaseListener.dart';

void main(List<String> arguments) async {
  if(arguments.isEmpty) {
    print("No directory specified!");
    exitCode=1;
    return;
  }
  if(arguments.length!=1) {
    print("Just one directory, please!");
    exitCode=1;
    return;
  }

  ArgResults argResults = ArgParser().parse(arguments);
  final paths = argResults.rest;
  
  final dir = Directory(
      paths.first);
  final List<FileSystemEntity> entities =
      await dir.list().where((e) => e is File && e.path.endsWith('dart')).toList();
  for (var o in entities) {
    print(o.path);
    InputStream input = await InputStream.fromPath(o.path);
    Lexer lexer = DartLexer(input);
    TokenStream tokenStream = CommonTokenStream(lexer);
    DartParser parser = DartParser(tokenStream);

    parser.buildParseTree = true;
    ParseTreeWalker.DEFAULT.walk(ConcreteListener(),parser.libraryDefinition());
  }
}

class ConcreteListener extends DartParserBaseListener{
  @override
    void exitDeclaration(DeclarationContext ctx) {
      //print(ctx.text);
    }
  @override
  void exitImportOrExport(ImportOrExportContext ctx) {
    print(ctx.libraryImport()!.text);
  }
}