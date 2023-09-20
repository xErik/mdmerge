Use placeholders in Markdown files to include other Markdown, text, or source files.

Placeholder statements are either (a) relative to the current Markdown file or (b) relative to the current working directory. Dart files are wrapped in code--dart-markdown.

**Updating exitsting Markdown files**

The resulting files are either (a) copied to an `output` directory or (b) overwrite the existing Markdown files in place. In the latter case, make a backup before running, things can go wrong.

Updating / overwriting Markdown files preserves the placeholder. Thus, updating / overwriting of already overwritten Markdown files can be repeated.

```markdown
# Markdown file 

## Include Markdown file

<include file="child.md"></include>

## Include dart file

<include file="lib/mdmerge.dart"></include>
```

# Installation 

Activate:

```shell
dart pub global activate mdmerge
```

# Usage

Per default Markdown files in `input` will be checked for placeholder. If `output` is not specified the source Markdown files will be updated with the referenced content.

Thus, `--dry-run` is the default, it will **simulate** updates only. 

```shell
dart run mdmerge include

dart run mdmerge include --input <DIR> --output <DIR>

dart run mdmerge include --input <FILE> --output <DIR>
```

```
dart run mdmerge include --help

Include text files in markdown files.

Usage: mdmerge include [arguments]
-h, --help            Print this usage information.
-i, --input           Director or file
                      (defaults to ".")
-o, --output          If not empty, write Markdown files into this directory
                      (defaults to "")
-s, --suffix          Scan Markdown files
                      (defaults to ".md")
    --[no-]dry-run    Will not write resulting files
```

# Information

This package has been written *off the cuff*, make a backup before using it.

## TODO

- Encapsulate logic in a class.
- Tests.