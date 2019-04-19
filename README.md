# Instructions for running the codes

## (1) Create data/ subfolder and download data files

Run `src/0-download-data.sh` from root of this repository


## (2) Run main scripts

### Option 1 : Running using `R`

Main script is `src/main.R`

R SessionInfo() dump for reference (to replicate session envt, including relevant packages and versions) : 

```
> sessionInfo()

R version 3.5.3 (2019-03-11)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 18.04.2 LTS

Matrix products: default
BLAS: /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.7.1
LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.7.1

locale:
 [1] LC_CTYPE=en_SG.UTF-8       LC_NUMERIC=C               LC_TIME=en_SG.UTF-8       
 [4] LC_COLLATE=en_SG.UTF-8     LC_MONETARY=en_SG.UTF-8    LC_MESSAGES=en_SG.UTF-8   
 [7] LC_PAPER=en_SG.UTF-8       LC_NAME=C                  LC_ADDRESS=C              
[10] LC_TELEPHONE=C             LC_MEASUREMENT=en_SG.UTF-8 LC_IDENTIFICATION=C       

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] bindrcpp_0.2.2  jsonlite_1.5    lubridate_1.7.4 stringr_1.3.1   magrittr_1.5   
[6] tidyr_0.8.1     dplyr_0.7.6    

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.1       fansi_0.3.0      utf8_1.1.4       crayon_1.3.4     assertthat_0.2.0
 [6] R6_2.2.2         pillar_1.3.0     cli_1.0.1        stringi_1.2.4    rlang_0.2.2     
[11] rstudioapi_0.7   tools_3.5.3      glue_1.3.0       purrr_0.2.5      yaml_2.2.0      
[16] compiler_3.5.3   pkgconfig_2.0.2  bindr_0.1.1      tidyselect_0.2.4 tibble_1.4.2
```

### Option 2 : Run with `Python`

Run Jupyter notebook `src/main.ipynb`.






