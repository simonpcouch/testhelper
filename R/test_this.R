#' Write unit tests for selected code
#'
#' @description
#' This function queries an LLM to write unit tests for selected R code. To do
#' so, it:
#'
#' * Initializes a [test_helper()]: an elmer [Chat()][elmer::Chat()] that knows how
#'   to write testthat unit tests.
#' * Reads the contents of the active `.R` file as well as the current selection.
#' * Opens a corresponding test file (creating it if need be).
#' * Asks the LLM to write unit tests for the current selection, using the
#'   contents of the active `.R` file as context.
#' * Streams the response into the corresponding test file.
#'
#' @returns
#' `TRUE`, invisibly.
#'
#' @export
test_this <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  test_helper <- retrieve_test_helper()

  # TODO: ensure that the file is a .R file in an `R/` directory
  turn <- assemble_turn(context)

  test_file <- open_test(context$path)

  tryCatch(
    stream_inline(
      test_helper = test_helper$clone(),
      turn = turn
    ),
    error = function(e) {
      rstudioapi::showDialog(
        "Error",
        paste("The test_helper ran into an issue: ", e$message)
      )
    }
  )

  invisible(TRUE)
}

assemble_turn <- function(context) {
  # TODO: handle case where there's nothing there, in which case test
  # the whole document
  paste0(
    c(
      "## Context",
      "",
      context$contents,
      "",
      "Now, here's the selection you'll write tests for.",
      "",
      "## Selection",
      "",
      rstudioapi::primary_selection(context)$text
    ),
    collapse = "\n"
  )
}

# TODO: more variables can be replaced with constants here, and logic
# probably simplified further
stream_inline <- function(test_helper, turn) {
  context <- rstudioapi::getSourceEditorContext()
  selection <- context$selection
  selection$range <- initial_range(context)

  output_lines <- character(0)
  stream <- test_helper$stream(turn)
  coro::loop(for (chunk in stream) {
    if (identical(chunk, "")) {next}
    output_lines <- paste(output_lines, sub("\n$", "", chunk), sep = "")
    n_lines <- nchar(gsub("[^\n]+", "", output_lines)) + 1
    if (n_lines < 1) {
      output_padded <-
        paste0(
          output_lines,
          paste0(rep("\n", 2 - n_lines), collapse = "")
        )
    } else {
      output_padded <- paste(output_lines, "\n")
    }

    rstudioapi::modifyRange(
      selection$range,
      output_padded %||% output_lines,
      selection$id
    )

    n_selection <- selection$range$end[[1]] - selection$range$start[[1]]
    n_lines_res <- nchar(gsub("[^\n]+", "", output_padded %||% output_lines))
    if (n_selection < n_lines_res) {
      selection$range$end[["row"]] <- selection$range$start[["row"]] + n_lines_res
    }
  })

  rstudioapi::setCursorPosition(selection$range$start)
}

initial_range <- function(context) {
  n_lines <- length(context$contents)
  last_line_start <- rstudioapi::document_position(n_lines, 1)
  last_line_end <- rstudioapi::document_position(n_lines, 100000)

  rstudioapi::modifyRange(
    rstudioapi::document_range(last_line_start, last_line_end),
    paste0(context$contents[n_lines], "\n"),
    id = context$id
  )

  # TODO: set selection to the "right" place in the test file
  # if it exists--perhaps as an LLM tool call?
  new_loc <- rstudioapi::document_position(n_lines + 1, 1)
  rstudioapi::document_range(new_loc, new_loc)
}
