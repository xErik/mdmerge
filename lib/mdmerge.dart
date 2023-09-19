import 'dart:io';

import 'package:args/command_runner.dart';

class MergeCommand extends Command {
  @override
  final name = "include";
  @override
  final description = "Include text files in markdown files.";

  MergeCommand() {
    argParser.addOption('input', abbr: 'i', defaultsTo: '.');
    argParser.addOption('output', abbr: 'o', defaultsTo: 'mdmerge');
    argParser.addOption('suffix', abbr: 's', defaultsTo: '.md');
    argParser.addFlag('dry-run', defaultsTo: false);
  }

  // [run] may also return a Future.
  @override
  void run() {
    work(
      argResults!['input'],
      argResults!['output'],
      argResults!['suffix'],
      argResults!['dry-run'],
    );
  }
}

main(List<String> args) {
  var runner = CommandRunner("mdmerge", "Include text files in markdown files");
  runner.addCommand(MergeCommand());
  runner.run(args).catchError((error) {
    if (error is! UsageException) throw error;
    print(error);
    exit(64); // Exit code 64 indicates a usage error.
  });
}

work(
  final String input,
  final String output,
  final String suffix,
  final bool isDryRun,
) {
  int allFileCount = 0;
  int includeFileCount = 0;
  int includeStatementCount = 0;
  int includeStatementFailedCount = 0;
  final RegExp rex = RegExp(r'\[include:(.*?)\]');
  // Do not match ourselves
  final RegExp rexIgnore = RegExp('\\?[include:(.*?)\\?]');

  getFiles(input, suffix).forEach((File fileRead) {
    allFileCount++;
    String fileContent = fileRead.readAsStringSync();

    _log(fileRead.path);

    if (rex.hasMatch(fileContent)) {
      bool isFileChanged = false;
      includeFileCount++;
      rex.allMatches(fileContent).forEach((match) {
        final includeStatement = match[0]!;
        final includeFilePath = match[1]!.trim();

        if (rexIgnore.hasMatch(includeStatement)) {
          // _log('  ignoring own basic pattern');
        } else {
          final File? includeFile = findFile(includeFilePath, fileRead.parent);

          if (includeFile != null) {
            includeStatementCount++;
            final includeContent = includeFile.readAsStringSync();
            fileContent =
                fileContent.replaceAll(includeStatement, includeContent);
            isFileChanged = true;
            _log('  including $includeFilePath');
          } else {
            includeStatementFailedCount++;
            _log('  included not found: $includeStatement      FAILED');
          }
        }
      });
      if (isFileChanged) {
        writeProtected(fileRead, fileContent, isDryRun, suffix, output);
      }
    } else {
      _log('  no include found');
    }
  });

  _log('\nStart dir $input');
  _log('Checked $suffix files: $allFileCount');
  _log('Modified $suffix files: $includeFileCount');
  _log('Included files: $includeStatementCount');
  _log('Included files failures: $includeStatementFailedCount\n');

  if (isDryRun) {
    _log('Dry run, merge files with flag --no-dry-run\n');
  }
}

List<File> getFiles(String input, String suffix) {
  final dir = Directory(input);
  final file = File(input);

  if (dir.existsSync() == false && file.existsSync() == false) {
    throw "Provided 'input' is neither a director nor a file.";
  }

  return dir.existsSync()
      ? Directory(input)
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith(suffix))
          .toList()
      : [file];
}

File? findFile(String includeFilePath, Directory currentFileDir) {
  String path = includeFilePath;
  if (File(path).existsSync() == false) {
    path = currentFileDir.path + Platform.pathSeparator + includeFilePath;
  }
  final file = File(path);

  if (file.existsSync()) {
    return file;
  }
  return null;
}

void writeProtected(
    File file, String contents, bool isDryRun, String suffix, String output) {
  String action = 'writing';

  final dir = Directory('$output${Platform.pathSeparator}${file.parent.path}');
  dir.createSync(recursive: true);

  final outFile =
      File(dir.path + Platform.pathSeparator + file.uri.pathSegments.last);

  if (isDryRun == false) {
    _log('  $action ${outFile.path}');
    outFile.writeAsStringSync(contents);
  } else {
    _log('  $action ${outFile.path} (simulated)');
  }
}

// void _log(String message) => log(message, name: 'markdown merge');
void _log(String message) => print(message);
