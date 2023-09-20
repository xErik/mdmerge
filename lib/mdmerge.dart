import 'dart:io';

import 'package:args/command_runner.dart';

/// Helper class
class MergeCommand extends Command {
  @override
  final name = "include";
  @override
  final description = "Include text files in markdown files.";

  MergeCommand() {
    argParser.addOption('input',
        abbr: 'i', defaultsTo: '.', help: 'Director or file');
    argParser.addOption('output',
        abbr: 'o',
        defaultsTo: '',
        help: 'If not empty, write markdown files into this directory');
    argParser.addOption('suffix',
        abbr: 's', defaultsTo: '.md', help: 'Scan markdown files');
    argParser.addFlag('dry-run',
        defaultsTo: true, help: 'Will not write resulting files');
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

  final RegExp rex =
      RegExp(r'\<include\s+file="(.*?)"\s*\>[\S\s]*?\<\/include\>');
  String ignoreSelf =
      r'<include file="$includeFilePath">$prefix$includeContent$postfix</include>';

  getFiles(input, suffix).forEach((File fileSource) {
    allFileCount++;
    String fileSourceContent = fileSource.readAsStringSync();

    _log(fileSource.path);

    if (rex.hasMatch(fileSourceContent)) {
      bool isFileChanged = false;
      includeFileCount++;

      rex.allMatches(fileSourceContent).forEach((match) {
        final includeStatement = match[0]!;
        final includeFilePath = match[1]!.trim();

        if (ignoreSelf == includeStatement) {
          _log('  ignoring own basic pattern');
        } else {
          final File? includeFile =
              findFile(includeFilePath, fileSource.parent);

          if (includeFile != null) {
            includeStatementCount++;
            final includeContent = includeFile.readAsStringSync();

            String prefix = '';
            String postfix = '';
            String ext = includeFile.uri.pathSegments.last.split('.').last;

            switch (ext) {
              case 'dart':
                prefix = '\n\n```dart\n';
                postfix = '```\n';
              case 'js':
                prefix = '\n\n```javascript\n';
                postfix = '```\n';
              default:
            }

            fileSourceContent = fileSourceContent.replaceAll(includeStatement,
                '<include file="$includeFilePath">$prefix$includeContent$postfix</include>');

            isFileChanged = true;
            _log('  including $includeFilePath');
          } else {
            includeStatementFailedCount++;
            _log('  included not found: $includeFilePath      FAILED');
          }
        }
      });
      if (isFileChanged) {
        writeProtected(fileSource, fileSourceContent, isDryRun, suffix, output);
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

  output = output.isEmpty ? '.' : output;

  final dir = Directory('$output${Platform.pathSeparator}${file.parent.path}');
  if (isDryRun == false) {
    dir.createSync(recursive: true);
  }

  final outFile =
      File(dir.path + Platform.pathSeparator + file.uri.pathSegments.last);

  if (isDryRun == false) {
    _log('  $action ${outFile.path}');
    outFile.writeAsStringSync(contents, mode: FileMode.writeOnly);
  } else {
    _log('  $action ${outFile.path} (simulated)');
  }
}

void _log(String message) => print(message);
