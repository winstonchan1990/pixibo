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


# Key Data Processing Steps in analysis


## (1) Normalizing size strings before joining

For `Exchanges/Returns` data, original and exchanged sizes are obtained by concatenating the sizing system name `(original/exchanged)_size_system_name` together with the size name `(original/exchanged)_size_name`. The original and exchanged size string labels are then normalized to facilitate joining to other datasets.

For `Conversions` data, the purchased size string labels are already in the desired format, hence we just need to normalize the strings.

For the sake of this analysis, normalizing of size label strings is done in a straight-forward manner, which just includes:

* Removing whitespace
* Converting to lowercasing

The caveat is that this will not account for other vagaries in inconsistent string labelling such as spelling differences / typo errors (which we have to assume are minimal enough to not affect analysis results).


## (2) Consolidating unique records in datasets

To remove records that are potentially duplicates, we need to uniquely identify records in all datasets using a composite of the data fields provided.

### Exchange / Returns data

Based on intuitive business logic, each record shall be uniquely identified by a composite of the following fields:

- **Order nr** : This is the transaction ID when a customer makes a purchase order (conversions)
- **SKU ID** : This is the product ID inside the "shopping cart" in the purchase order (transaction ID)
- **original_size** : For each transaction, the customer may purchase different sizes for the same product (SKUID)

To consolidate all records, we firstly remove duplicate rows in the dataset. 467 out of the 91242 records of interest (<1%) were found to be duplicates and dropped. 

The remaining 90775 records may have multiple **Reason Returns** and **exchanged_sizes**, so we handle them by concatenating all **Reason Return** and **exchanged_size** respectively for each unique record. 35 out of the 90775 records correspond to records with more than 1 **Reason Return** (both too big and too small).

This leaves us with 90740 records uniquely identified by Transaction ID, Product ID and Product Size purchased.


### Conversions data

Within the analysis period range of 1 Feb 2019 to 28 Feb 2019, each record in the JSON stream data dump corresponds to 1 unique transaction ID. We are interested in the product information within each transaction record. Each record shall be uniquely identified by the composite of the following:

- **transaction** : the transaction ID when customer makes a purchase order
- **SKU** : the product ID purchased in the transaction
- **size** : size of product purchased in the transaction; customer may purchase > 1 size types for the same product ID in 1 transcation
- **quantity** : how many units of each product of a specific size did the customer purchase in the transaction
- **price** : price per unit paid for each product of a particular size in the transcation

*Note: the reason for including quantity and price in the composite key is to account for possibility that the same product (same SKU, same size) was purchased at different prices within the same purchase order (eg. promotion offer to buy 1st 3 units of the product at $10 then subsequent units at $8?) 

No duplicate records were found. Total number of records : 8578 for the analysis period from 1 Feb 2019 to 28 Feb 2019.



## (3) Merging datasets


### Matching purchased products with exchange/return records

(..to be continued)










