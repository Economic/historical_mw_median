## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(
  
  tar_file(fed_mw_raw, "data_raw/fed_min_wage.csv"),
  
  fed_mw_annual = create_fed_mw_annual(fed_mw_raw),
  asec_raw = download_ipums_extract(),
  asec_cleaned = clean_asec(asec_raw),
  org_cleaned = clean_org(),
  historical_kaitz = create_historical_kaitz(
    asec_cleaned, 
    fed_mw_annual,
    org_cleaned
  )

)
