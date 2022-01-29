# Historical BTC and ETH minute data in sql format

This contains the minute candles as found at https://www.cryptodatadownload.com/data/bitstamp/

Notice from the site:
>"CryptoDataDownload makes available free data for cryptocurrency enthusiasts or risk analysts to do their own research or practice their skills."

*Note: if you represent CryptoDataDownload and have any issue with this on github please contact me and we can resolve as needed.*

This project: 
1. mirrors bitstamp data
2. generated a sql file that contains queries to insert data (quickly)

This repo is to derive a list of sql commands which can be inserted by psql. It contains the output and the source code used to generate it.

heres an example table to add to your project:

```
-- historical data for backtesting
CREATE TABLE price_index_history (
  "id"        serial not null unique primary key,
  "date"      timestamp not null default NOW(),
  "f"         varchar not null,
  "t"         varchar not null,
  "open"      numeric(40,6) not null,
  "close"     numeric(40,6) not null,
  "high"      numeric(40,6) not null,
  "low"       numeric(40,6) not null,
  "volume"    numeric(40,6) not null,
  "createdAt" timestamp not null default NOW(),
  "updatedAt" timestamp not null default NOW()
)
```
Be sure to index the date column so SQL doesnt have to search 5 million rows every time:
`CREATE INDEX idx_price_index_history_date on price_index_history(date);`

The data has already been compiled. I have included the source code that compiled the data to support future datasets or other currencies. (CryptoDataDownload also provides a few less significant pairs)

Add the table above to your database and then in psql run the addAll.sql file and thats it:

`psql> \cd data`
`psql \i runAll.sql`
