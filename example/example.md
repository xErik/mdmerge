# Installation 

Activate:
```shell
dart pub global activate mdmerge
```

# Placeholders

Add these placeholders to markdown files, the comment tags require three (!) dashes:

```markdown
# Markdown file 

## Include Markdown file

<include file="child.md"></include>

## Include dart file

<include file="lib/mdmerge.dart"></include>
```

# Run

Dry-run is on per default, will run simulation only:

```shell
dart run mdmerge include --input <DIR> 
```

Write to output directory: 

```shell
dart run mdmerge include --input <DIR> --output <DIR> --no-dry-run
```

Overwrite source files (potentially destructive, make a backup): 

```shell
dart run mdmerge include --input <DIR> --no-dry-run
```
