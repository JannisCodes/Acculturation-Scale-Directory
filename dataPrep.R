lib <- c("rmarkdown", "knitr", "remedy", "bookdown", "rmdfiltr", "psych", "janitor", "rvest",
         "data.table", "dplyr", "tidyr", "Hmisc", "kableExtra", "readxl", "stringr", "reshape2")
invisible(lapply(lib, library, character.only = TRUE))  
rm(lib) 

load("../acculturation-review/data/AcculturationScales.RData")

dt.Scales.Included <- dt.Scales.Included %>%
  mutate(id = seq.int(nrow(dt.Scales.Included)))

# prepare reference section
render("scale-references.Rmd")
refHtml <- read_html("scale-references.html")
refTbl <- html_nodes(refHtml, "table")
referencesShort <- as.data.frame(html_table(refTbl))

# clean up line breaks from Excel file to fit with HTML line breaks
dt.Scales.Included <- merge(dt.Scales.Included, referencesShort %>% dplyr::select(-Scale), by = "id") %>%
  mutate(Item = str_replace_all(Item, "\n", "<br>"),
         ResponseRangeAnchors = str_replace_all(ResponseRangeAnchors, "\n", "<br>"),
         nlifeDomain = str_count(lifeDomain, ',')+1,
         lifeDomain = str_replace_all(lifeDomain, ",", "<br>"),
         NItems = as.numeric(NItems))

refSec <- paste(html_nodes(refHtml, "[id='refs']"))

updateDate <- Sys.time()

save(dt.Scales, dt.Scales.Included, refSec, updateDate, file = "scales-data.RData")