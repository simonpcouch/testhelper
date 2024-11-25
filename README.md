
<!-- README.md is generated from README.Rmd. Please edit that file -->

# assure

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/assure)](https://CRAN.R-project.org/package=assure)
[![R-CMD-check](https://github.com/simonpcouch/assure/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simonpcouch/assure/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The assure package provides an addin for drafting testthat unit
testing code using LLMs. Triggering the addin will open a corresponding
test file and begin writing tests into it. The assure *test helper*
is familiar with testthat 3e as well as tidy style, and incorporates
context from the rest of your R package to write concise and relevant
tests.

## Installation

You can install assure like so:

``` r
pak::pak("simonpcouch/assure")
```

Then, ensure that you have an
[`ANTHROPIC_API_KEY`](https://console.anthropic.com/) environment
variable set, and you’re ready to go. If you’d like to use an LLM other
than Anthropic’s Claude 3.5 Sonnet—like OpenAI’s ChatGPT—to power the
test helper, see the `test_helper()` documentation.

The test helper is interfaced with the via the RStudio addin
“assure: Test R code.” For easiest access, we recommend registering
the assure addin to a keyboard shortcut. **In RStudio**, navigate to
`Tools > Modify Keyboard Shortcuts > Search "assure"`—we suggest
`Ctrl+Alt+T` (or `Ctrl+Cmd+T` on macOS). The test helper is currently
not available in Positron as Positron has yet to implement document
`id`s that assure needs to toggle between source and test files.

Once those steps are completed, you’re ready to use the assure addin
with a keyboard shortcut.

## Example

To use the test helper, just trigger the addin (optionally selecting
some code to only write tests for a certain portion of the file) and
watch your testing code be written.

![](https://raw.githubusercontent.com/simonpcouch/assure/refs/heads/main/inst/figs/assure.gif)