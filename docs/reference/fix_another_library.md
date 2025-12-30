# Fix a User-Project Library

Sometimes, the user_project library can break. This can happen if there
are failures in the upstream install functions. Or if the links are
deleted for some reason. If everything is broken, you may need to repair
the user project library. To do this, exit the project and enter a
working project. Delete the links in the offending user project library.
Then run this function to relink. Use either the library catalog file
from the project itself, or if this is also corrupted with bad
information, run an older version that worked or a version from another
project that worked. If you can identify the problematic package in the
course of these fixes, then you should probably delete it from your
cache entirely.

## Usage

``` r
fix_another_library(file, dir)
```

## Arguments

- file:

  The library catalog tsv file to read from.

- dir:

  The user project library to repair.

## Value

Nothing

## See also

[`path_math`](https://fs.r-lib.org/reference/path_math.html),
[`create`](https://fs.r-lib.org/reference/create.html),
[`path`](https://fs.r-lib.org/reference/path.html),
[`path_file`](https://fs.r-lib.org/reference/path_file.html)
[`read_delim`](https://readr.tidyverse.org/reference/read_delim.html)
[`pull`](https://dplyr.tidyverse.org/reference/pull.html)
