# Reset Your Console Prompt

The prompt package adds a nice feature but has some limitations, namely,
that it does not respect changing git branches and has to be manually
re-called. This defeats the purpose. Blasertemplates git functions
automoatically call prompt to change the prompt label when switching
branches, but this will not happen if you change branches using the
terminal, the git panel or other git branching functions. Therefore this
function is provided to manually reset your prompt to the current
branch.

## Usage

``` r
reset_prompt()
```

## Value

nothing

## See also

[`set_prompt`](https://rdrr.io/pkg/prompt/man/set_prompt.html),[`prompt_git`](https://rdrr.io/pkg/prompt/man/prompt_git.html)
