CREATE TABLE real_time_data (
    id STRING,
    timestamp TIMESTAMP_LTZ,
    price FLOAT,"Big Data Assignment".PUBLIC."crop_data"
    yield FLOAT,
    source STRING
);

CREATE OR REPLACE STREAM real_time_data_stream ON TABLE real_time_data;

CREATE OR REPLACE TASK process_real_time_data
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 MINUTE'
AS
INSERT INTO processed_data_table
SELECT * FROM real_time_data_stream;

ALTER TASK process_real_time_data RESUME;
