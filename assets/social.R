# # MIT License
# 
# Copyright (c) 2021 Mickaël Canouil
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

library(chromote)
library(callr)
library(rmarkdown)
library(qpdf)
library(pdftools)
library(jsonlite)

social <- function(input, output, rmd_params, chrome_path, delay = 1) {
  print_to_pdf <- function(input, output, rmd_params, chrome_path, delay = 1) {
    devnull <- sapply(
      X = file.path(output, c("materials", "ads")),
      FUN = dir.create, showWarnings = FALSE, recursive = TRUE
    )
    file.create(file.path(output, c("materials", "ads"), ".gitkeep"))

    xaringan_poster <- rmarkdown::render(
      input = input,
      output_dir = tempdir(),
      encoding = "UTF-8",
      params = rmd_params
    )
    on.exit(unlink(xaringan_poster))

    web_browser <- suppressMessages(try(chromote::ChromoteSession$new(), silent = TRUE))

    if (
      inherits(web_browser, "try-error") &&
      missing(chrome_path) &&
      Sys.info()[["sysname"]] == "Windows"
    ) {
      edge_path <- "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" # remove hard-coded path at some point
      if (file.exists(edge_path)) {
        Sys.setenv(CHROMOTE_CHROME = edge_path)
        web_browser <- chromote::ChromoteSession$new()
      } else {
        stop('Please set Sys.setenv(CHROMOTE_CHROME = "Path/To/Chrome")')
      }
    }

    web_browser$Page$navigate(xaringan_poster, wait_ = TRUE)
    on.exit(web_browser$close(), add = TRUE)
    web_browser$Page$loadEventFired()

    # web_browser$screenshot(
    #   filename = sprintf("%s/ads/%s.png", output, basename(output)),
    #   selector = "div.remark-slide-scaler",
    #   scale = 2
    # )

    current_slide <- function() {
      x <- web_browser$Runtime$evaluate("slideshow.getCurrentSlideIndex()")$result$value
      as.integer(x) + 1L
    }

    slide_is_continuation <- function() {
      web_browser$Runtime$evaluate(
        "document.querySelector('.remark-visible').matches('.has-continuation')"
      )$result$value
    }

    hash_current_slide <- function() {
      digest::digest(web_browser$Runtime$evaluate(
        "document.querySelector('.remark-visible').innerHTML"
      )$result$value)
    }

    expected_slides <- as.integer(
      web_browser$Runtime$evaluate("slideshow.getSlideCount()")$result$value
    )

    max_slides <- expected_slides# * 4

    # slide_size <- ({
    #   r <- web_browser$Runtime$evaluate("slideshow.getRatio()")$result$value
    #   r <- lapply(strsplit(r, ":"), as.integer)
    #   width <- r[[1]][1]
    #   height <- r[[1]][2]
    #   page_width <- 8 / width * width
    #   list(
    #     width = as.integer(908 * width / height),
    #     height = 681L,
    #     page = list(width = page_width, height = page_width * height / width)
    #   )
    # })

    web_browser$Browser$setWindowBounds(1, bounds = list(
      width = 1920,
      height = 1080
    ))

    web_browser$Emulation$setEmulatedMedia("print")
    web_browser$Runtime$evaluate(paste0(
      "let style = document.createElement('style')\n",
      "style.innerText = '@media print { ",
      ".remark-slide-container:not(.remark-visible){ display:none; }",
      "}'\n",
      "document.head.appendChild(style)"
    ))

    idx_slide <- current_slide()
    last_hash <- ""
    idx_part <- 0L
    pdf_files <- vector("character", max_slides)
    for (i in seq_len(max_slides)) {
      if (i > 1) {
        web_browser$Input$dispatchKeyEvent(
          "rawKeyDown",
          windowsVirtualKeyCode = 39,
          code = "ArrowRight",
          key = "ArrowRight",
          wait_ = TRUE
        )
      }

      if (current_slide() == idx_slide) {
        idx_part <- idx_part + 1L
      } else {
        idx_part <- 1L
      }
      idx_slide <- current_slide()

      if (slide_is_continuation()) next
      Sys.sleep(delay)

      this_hash <- hash_current_slide()
      if (identical(last_hash, this_hash)) break
      last_hash <- this_hash

      pdf_file_promise <- web_browser$Page$printToPDF(
        landscape = TRUE,
        printBackground = TRUE,
        paperWidth = 16,
        paperHeight = 9,
        marginTop = 0,
        marginRight = 0,
        marginBottom = 0,
        marginLeft = 0,
        pageRanges = "1",
        preferCSSPageSize = TRUE,
        wait_ = FALSE
      )$then(function(value) {
        filename <- tempfile(fileext = ".pdf")
        writeBin(jsonlite::base64_dec(value$data), filename)
        filename
      })
      pdf_files[[i]] <- web_browser$wait_for(pdf_file_promise)
    }

    output_pdf <- sprintf("%s/ads/%s.pdf", output, basename(output))
    output_png <- sprintf("%s/ads/%s.png", output, basename(output))
    qpdf::pdf_combine(pdf_files, output = output_pdf)
    suppressWarnings(pdftools::pdf_convert(
      pdf = output_pdf,
      format = "png",
      pages = 1,
      filenames = output_png,
      verbose = FALSE
    ))
    unlink(pdf_files)

    invisible(output_pdf)
  }
  callr::r(
    func = print_to_pdf,
    args = list(
      input = input,
      output = output,
      rmd_params = rmd_params,
      delay = delay
    )
  )
}
