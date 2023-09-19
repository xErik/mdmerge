Include text files in markdown files.

This is a command line application, detecting include patterns in `.md` files and replacing the content accordingly. 

Paths may be relative to the current `.md` file or reference the current working directory.

[include:child.md]

[include:./example/example.dart]

# Installation 

Activate:

```shell
dart pub global activate mdmerge
```

Run:

```shell
dart run mdmerge include  --input <DIR> --output <DIR>
```

Or include the package as a dev dependency:

```shell
dart pub add dev:mdmerge
```

# Usage

By default all `.md` files will be checked for included text files:

```shell
dart run mdmerge include

dart run mdmerge include --input <DIR> --output <DIR>

dart run mdmerge include --input <FILE> --output <DIR>
```

```
dart run mdmerge include --help

Usage: mdmerge include [arguments]
-h, --help            Print this usage information.
-i, --input           (defaults to ".")
-o, --output          (defaults to "mdmerge")
-s, --suffix          (defaults to ".md")
    --[no-]dry-run
```

# Information

This package has been written *of the cuff*.

## TODO

- Encapsulate logic in a class.