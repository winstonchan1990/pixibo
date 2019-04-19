#################
### Libraries ###
#################

library(dplyr)
library(tidyr)
library(magrittr)
library(stringr)
library(lubridate)
library(jsonlite)

###########################
### Paths to data files ###
###########################

## Exchanges and Returns
FILEPATH_DATA_EXCHANGES_RETURNS = 'data/data_science_exchanges_returns.file'

## Conversions
FILEPATH_DATA_CONVERSIONS = 'data/data_science_test_conversions.file'


###################################
## Start / End Dates of Analysis ##
###################################

ORDER_START_DATE = as.Date('2019-02-01') # 1 feb 2019
ORDER_END_DATE = as.Date('2019-02-28') # 28 feb 2019


#########################
## Exchanges / Returns ##
#########################


### Read exchange/returns data (tsv file)
DATA_EXCHANGE_RETURNS = read.delim(
  file = FILEPATH_DATA_EXCHANGES_RETURNS,
  sep = '\t',
  stringsAsFactors = FALSE
)

### Filter for 'size does not fit" reasons
DATA_EXCHANGE_RETURNS = DATA_EXCHANGE_RETURNS %>% filter(
  str_detect(Reason.Name,'size_does_not_fit')
)

### To remove possibly duplicated records:

### Get all unique records of products that were returned/exchanged, 
### uniquely identified by a composite of the following :
### - Order.Nr : transaction id
### - SKU.ID : product id
### - Original Size System Name + Name : size/fit of product purchased

DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS = DATA_EXCHANGE_RETURNS %>% 
  mutate(size_exchangedreturned = paste(
    original_size_system_name,
    original_size_name,
    sep=' '
  )) %>%  
  select(
    Order.nr,
    SKU.ID,
    size_exchangedreturned,
    Reason.Name
  ) %>%
  distinct()

# For each unique record, concat all the Reason.Names (if more than 1)
# to ensure 1 row per record
DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS = DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS %>%
  group_by(
    Order.nr,
    SKU.ID,
    size_exchangedreturned
  ) %>%
  summarise(Reason.Name = paste(Reason.Name,collapse=' _AND_ '))

# normalize size char string (to join to conversion data)
DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS$size_exchangedreturned = DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS$size_exchangedreturned %>%
  str_trim() %>%
  str_replace_all("\\s+","_") %>%
  tolower()




#################
## Conversions ##
#################

### Read in conversions (streaming JSON dump)
DATA_CONVERSIONS_ALL = stream_in(
  con = file(FILEPATH_DATA_CONVERSIONS)
)

# fields to extract are in nested dataframe in _source field
DATA_CONVERSIONS = DATA_CONVERSIONS_ALL$`_source`

# select fields of interest
DATA_CONVERSIONS = DATA_CONVERSIONS %>% select(
  transaction,
  products,
  timestamp
)

# Extract date from timestamp
DATA_CONVERSIONS$date = DATA_CONVERSIONS$timestamp %>%
  str_extract('\\d{4}-\\d{2}-\\d{2}') %>%
  as.Date()

# Filter for orders (ie transactions) within time range of interest
DATA_CONVERSIONS = DATA_CONVERSIONS %>% filter(
  date >= ORDER_START_DATE,
  date <= ORDER_END_DATE 
)


###############################################################
## Seperate out transaction product info into seperate table ##
###############################################################

DATA_CONVERSIONS_PRODUCTS = DATA_CONVERSIONS %>% 
  select(transaction,products) %>%
  unnest()

## Remove transactions with no product info
## (22 out of 4705 products)

# length(unique(DATA_CONVERSIONS_PRODUCTS$transaction)) # 4705

# DATA_CONVERSIONS_PRODUCTS %>%  
  # filter(is.na(sku)|str_detect(sku,'undefined')) %>%
  # pull(transaction) %>%
  # unique ## 22

DATA_CONVERSIONS_PRODUCTS = DATA_CONVERSIONS_PRODUCTS %>%
  filter(!is.na(sku)) %>% 
  filter(!str_detect(sku,'undefined'))


# cast transaction to integer
DATA_CONVERSIONS_PRODUCTS$transaction = as.integer(DATA_CONVERSIONS_PRODUCTS$transaction)

# normalize size char string (to join with return/)
DATA_CONVERSIONS_PRODUCTS$size = DATA_CONVERSIONS_PRODUCTS$size %>%
  str_trim() %>%
  str_replace_all("\\s+","_") %>%
  tolower()

# Uniquely identify records of products purchased in transactions by:
# - transaction id (order number)
# - product id (sku)
# - size of product
# - price paid for product
# - quantity of product purchased at stated price and stated size

# check for duplicates:
# no duplicate rows found
DATA_CONVERSIONS_PRODUCTS %>%
  group_by(
    transaction,
    sku,
    size,
    price,
    quantity
  ) %>%
  tally(sort=TRUE) %>%
  pull(n) %>%
  range
  


################################################
## Merge Return/Exchange with Conversion Data ##
################################################

## Step 1 : To find TransactionID-SKUIDs that were returned, independent of size

DATA_CONVERSIONS_EXCHANGE_RETURNS = left_join(
  x = DATA_CONVERSIONS_PRODUCTS,
  y = DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS %>% 
    select(Order.nr,SKU.ID) %>%
    distinct() %>%
    mutate(ind_transaction_sku_exchangedreturned = 1),
  by = c(
    'transaction' = 'Order.nr',
    'sku'='SKU.ID'
  )
)

DATA_CONVERSIONS_EXCHANGE_RETURNS = DATA_CONVERSIONS_EXCHANGE_RETURNS %>% 
  replace_na(list(
    ind_transaction_sku_exchangedreturned = 0
  ))


## Step 2 : try to get reason for exchange/return by joining by 
## transaction id, product id and size
DATA_CONVERSIONS_EXCHANGE_RETURNS = left_join(
  x = DATA_CONVERSIONS_EXCHANGE_RETURNS,
  y = DATA_EXCHANGE_RETURNS_UNIQUE_RECORDS,
  by = c(
    'transaction' = 'Order.nr',
    'sku'='SKU.ID',
    'size'='size_exchangedreturned'
  )
)


##############
## Get UID  ##
##############

DATA_CONVERSIONS_UID = DATA_CONVERSIONS_ALL$`_source` %>%
  select(uid,transaction) %>%
  mutate(transaction=as.integer(transaction)) %>%
  filter(transaction %in% DATA_CONVERSIONS_EXCHANGE_RETURNS$transaction) %>%
  distinct()

##########################################################################
## TODO : Get Info on whether Conversion is Pixibo influenced purchase  ##
##########################################################################

# Pending events.json data to get
# - indicator of whether conversion is Pixibo influenced
# - size that was recommended by Pixibo (to compare with purchased size)






