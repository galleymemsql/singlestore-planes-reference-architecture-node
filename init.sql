create database maps;
use maps;


create rowstore table if not exists countries (
  boundary geography,
  name_short varchar(3),
  name varchar(50),
  name_long varchar(50),
  abbrev varchar(10),
  postal varchar(4),
  iso_a2 varchar(2),
  iso_a3 varchar(3),
  name_formal varchar(100),
  shard key(name)
);

-- Thanks to Natural Earth for this data
-- https://www.naturalearthdata.com/downloads/
create pipeline if not exists countries as
load data S3 'countries'
config '{"region": "us-east-1", "endpoint_url":"http://minio:9000/"}'
credentials '{"aws_access_key_id": "singlestore", "aws_secret_access_key": "minio123"}'
into table countries (boundary, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, name_short, @, name, name_long, @, @, @, abbrev, postal, name_formal, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, iso_a2, iso_a3, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @, @)
format CSV
fields terminated by ',' optionally enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

-- We only need to ingest the one file
start pipeline countries foreground limit 1 batches;


create rowstore table if not exists flights (
  load_date datetime NOT NULL,
  ica024 varchar(20),
  callsign varchar(20),
  origin_country varchar(300),
  time_position datetime,
  last_contact datetime,
  position geographypoint,
  longitude double,
  latitude double,
  baro_altitude double,
  on_ground bool NOT NULL,
  velocity double,
  true_track double,
  vertical_rate double,
  altitude double,
  squawk varchar(20),
  spi bool NOT NULL,
  position_source int NOT NULL,
  shard key(load_date, position)
);

-- Thanks to OpenSky Network for this data
-- https://opensky-network.org/apidoc/rest.html
create pipeline if not exists flights
as load data S3 'flights'
config '{"region": "us-east-1", "endpoint_url":"http://minio:9000/"}'
credentials '{"aws_access_key_id": "singlestore", "aws_secret_access_key": "minio123"}'
into table `flights`
format JSON;

start pipeline flights;
