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

library(callr)
library(rmarkdown)
library(xaringanBuilder)

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
    output_pdf <- sprintf("%s/ads/%s.pdf", output, basename(output))
    output_png <- sprintf("%s/ads/%s.png", output, basename(output))
    xaringanBuilder::build_pdf(xaringan_poster, output_file = output_pdf)
    xaringanBuilder::build_png(xaringan_poster, output_file = output_png)

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
