# Instructions for running the codes

## (1) Create data/ subfolder and download data files

Run `src/0-download-data.sh` from root of this repository.


## (2) Run main scripts

Run Jupyter notebook `src/main.ipynb`. The steps used to obtain the analysis results are in `src/main.html'.


# Key Data Processing Steps in analysis


## (1) Normalizing size strings before joining

For `Exchanges/Returns` data, original and exchanged sizes are obtained by concatenating the sizing system name `(original/exchanged)_size_system_name` together with the size name `(original/exchanged)_size_name`. The original and exchanged size string labels are then normalized to facilitate joining to other datasets.

For `Conversions` data, the purchased size string labels are already in the desired format, hence we just need to normalize the strings.

For the sake of this analysis, normalizing of size label strings is done in a straight-forward manner, which just includes:

* Removing whitespace
* Converting to lowercasing

The caveat is that this will not account for other vagaries in inconsistent string labelling such as spelling differences / typo errors (which we have to assume are minimal enough to not affect analysis results).

For `Events` data, some manual modifications to the labels were made for standardization with other datasets, namely:

* **AU** ==> **AUS** 
* **INT** ==> **INTERNATIONAL**

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

We merge by **transaction** and **sku** to check if the product purchased in the transaction was associated with any product returns/exchanges.

### Matching purchased products with size recommendations

We merge by **uid** and **sku** to check if a size recommendation was associated with the product purchase.


# Statistics to compute


We want to find out, for Pixbo influenced purchases *(ie. transaction-SKU pairs that are associated with size recommendations)*, 

1. Total products sold
2. Total products returned
3. Total prodicts returns / Total products sold

For each of the 3 statistics, we want to compute for 3 differnt subsets:

a. All Pixibo influenced product purchases

b. All Pixibo influenced product purchases whereby purchase size = recommended size

c. All Pixibo influenced product purchases whereby purchase size =/= recommended size


For each of the 3 count metrics, we can choose to count in 2 different ways:
    
1. Count Number of unique SKUs (regardless of transaction ID) **with at least 1 exchange/return record**
2. Count Number of unique Transaction-SKU pairs (in layman terms : *product purchases*) **with at least 1 exchange/return record**




The first metric would make sense if we are more focused on the performance over different unique products regardless of who purchases it, but the second metric would make more sense if we also want to take into account real-world business costs due to transaction volumes (eg. more transactions ==> more different customers to attend to for exchanging/returning ==> more transporation / inventory costs) 



# Overall Statistics

| Subset | count_type | total_products_sold | total_returns | return_rate |
|-------|---------------------------------------|---------------------|---------------|-------------|
| All Pixibo Influenced Transactions | Count By Unique SKU | 102 | 12 | 0.117647 |
| All Pixibo Influenced Transactions | Count By Unique Transaction-SKU pairs | 105 | 12 | 0.114286 |
| Purchased Recommended Size | Count By Unique SKU | 60 | 4 | 0.066667 |
| Purchased Recommended Size | Count By Unique Transaction-SKU pairs | 61 | 4 | 0.065574 |
| Did Not Purchased Recommended Size | Count By Unique SKU | 47 | 8 | 0.170213 |
| Did Not Purchased Recommended Size | Count By Unique Transaction-SKU pairs | 48 | 8 | 0.166667 |


*Note : Overlapping counts across different subsets are possible because `Purchase Recommended Size` and `Did Not Purchase Recommended Size` are not mutually exclusive. Eg. When a product purchase involves purchasing of more than 1 different sizes, it is possible for that SKUID to belong to both in the `Purchased Recommended Size` and the `Did Not Purchased Recommended Size` because the customer may have purchased both the recommended size and some other size (that was not recommended) in the same transaction.*

Based on the analysis of Pixibo influenced transactions in 2019 Feb, we observe that purchases that were made in accordance to the size recommendations of Pixibo had significantly lower return rates compared to purchases that were not made in accordance to the size recommendations, regardless of whether we count by SKU alone, or by Transaction-SKU pairs.

# Possible Refinements

One possible limitation would be the fact that this analysis does not consider the mapping between different sizes across
different systems, hence we only infer that the size recommendation and the purchased size is equal if both the system name and the size name are exactly the same. The analysis can be made more robust by making use of size mapping tables, but even then it also presents its own challenges as mapping tables may vary across different types of apparel.










