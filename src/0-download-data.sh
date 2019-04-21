mkdir data/
cd data/
curl https://s3-us-west-2.amazonaws.com/miscka/datascience/data_science_exchanges_returns.csv --output data_science_exchanges_returns.file
curl https://s3-us-west-2.amazonaws.com/miscka/datascience/data_science_test_conversions.csv --output data_science_test_conversions.file
curl https://s3-us-west-2.amazonaws.com/miscka/datascience/data_science_test_skus.json --output data_science_test_skus.file
curl https://s3-us-west-2.amazonaws.com/miscka/datascience/data_science_test_events.json --output data_science_test_events.file