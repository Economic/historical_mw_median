## library() calls go here
library(conflicted)
library(dotenv)
library(targets)
library(tarchetypes)

# conflicts
conflict_prefer("filter", "dplyr")

# packages for this analysis
library(tidyverse)
library(ipumsr)
library(rvest)
library(tsibble)
