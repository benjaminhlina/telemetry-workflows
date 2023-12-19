
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Telemetry Workflows

<!-- badges: start -->
<!-- badges: end -->

This repository is where I store example work-flows to do different data
cleaning operations (e.g., adding metadata, removing false detections,
creating preliminary abacus plots) for acoustic telemetry data. The
first step in these workflows are meant to be used with telemetry data
that doesn’t go through [Ocean Tracking Network
(OTN)](https://oceantrackingnetwork.org/) or affiliates (e.g., [Great
Lakes Acoustic Telemetry Observation System
(GLATOS)](https://glatos.glos.us/)), QAQC protocols. After step one, the
scripts can be used with [OTN](https://oceantrackingnetwork.org/) or
affiliates (e.g., [GLATOS](https://glatos.glos.us/)), QAQC data. If one
wants to use any of the scripts regardless of the where they are at with
their telemetry data, in the R folder, select the company your
transmitters and receivers are and choose what step you are wanting help
with.

NOTE: Currently Lotek files are under development and are limited in
functionality.

# Installation

To get this repo and the example workflows you can download it in R
using the following code and prompts:

``` r
install.packages("usethis")
usethis::use_course("https://github.com/benjaminhlina/telemetry-workflows/archive/refs/heads/master.zip")
```

Once installed click on the folder R to find the selected scripts.

# Questions and Contriubtions

If you have question about how to do something you want with telemetry
data but are unsure and you would like help. Please submit an
[issue](https://github.com/benjaminhlina/telemetry-workflows/issues) as
a [reprex](https://reprex.tidyverse.org/) marked with an enhancement tag
to help me, help you. I will not attempt to answer questions that do not
use a reprex, as it makes it difficult to troubleshoot what you’re
needing help with. If you have code you’d like to contribute to this,
please fork this repository and create a [pull
request](https://github.com/benjaminhlina/telemetry-workflows/pulls).
Thanks!
