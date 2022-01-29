DROP TYPE kline_set CASCADE;
CREATE TYPE kline_set AS (
    date timestamp,
    open numeric,
    close numeric,
    high numeric,
    low numeric,
    volume numeric
);

DROP FUNCTION get_kline_minute;
DROP FUNCTION get_kline_hour;
DROP FUNCTION get_kline_day;

CREATE OR REPLACE FUNCTION get_kline_minute(
  "Currency" varchar,
  "Ending" timestamp,
  "Interval" integer, -- in number of minutes
  "NumberOfRecords" integer
)
RETURNS SETOF kline_set
LANGUAGE plpgsql AS $$
DECLARE
  _r price_index_history%rowtype;
  _open numeric := 0;
  _train integer;
  _train_period integer := 2;
  _kline_set kline_set;
BEGIN
  _train = "NumberOfRecords" + 2;
  FOR _r IN
    SELECT * FROM price_index_history 
    WHERE f = "Currency" 
    AND "date" <= "Ending" 
    AND "date" > "Ending" - INTERVAL '1 MINUTE' * "Interval" * ("NumberOfRecords" + 2)
    AND DATE_PART('minute', date)::INTEGER % "Interval" = 0 
    ORDER BY DATE ASC LIMIT _train -- have to do asc here because of the way close data is generated.
  LOOP
    DECLARE
      _high numeric := 0;
      _low numeric := 0;
      _volume numeric := 0;
      _add boolean := false;
    BEGIN
      SELECT MAX(high), MIN(low), SUM(volume) INTO _high, _low, _volume FROM price_index_history
      WHERE f = "Currency"
      AND "date" <= _r.date AND "date" > _r.date - INTERVAL '1 MINUTE' * "Interval";
      IF _train_period > 0 THEN
        _train_period = _train_period - 1;
      ELSE
        _kline_set.date = _r.date;
        _kline_set.open = _open;
        _kline_set.close = _r.close;
        _kline_set.high = _high;
        _kline_set.low = _low;
        _kline_set.volume = _volume;
        _add = true;
      END IF;
      _open = _r.close; 
      IF _add THEN
        RETURN NEXT _kline_set;
      END IF;
    END;
  END LOOP;
  RETURN;
END;
$$;

CREATE OR REPLACE FUNCTION get_kline_hour(
  "Currency" varchar,
  "Ending" timestamp,
  "Interval" integer, -- in number of hours
  "NumberOfRecords" integer
)
RETURNS SETOF kline_set
LANGUAGE plpgsql AS $$
DECLARE
  _r price_index_history%rowtype;
  _open numeric := 0;
  _train integer;
  _train_period integer := 2;
  _kline_set kline_set;
BEGIN
  _train = "NumberOfRecords" + 2;
  FOR _r IN
    SELECT * FROM price_index_history 
    WHERE f = "Currency" 
    AND "date" <= "Ending" 
    AND "date" > "Ending" - INTERVAL '1 HOUR' * "Interval" * ("NumberOfRecords" + 2)
    AND DATE_PART('hour', date)::INTEGER % "Interval" = 0 
    AND DATE_PART('minute', date)::INTEGER = 0
    ORDER BY DATE ASC LIMIT _train -- have to do asc here because of the way close data is generated.
  LOOP
    DECLARE
      _high numeric := 0;
      _low numeric := 0;
      _volume numeric := 0;
      _add boolean := false;
    BEGIN
      SELECT MAX(high), MIN(low), SUM(volume) INTO _high, _low, _volume FROM price_index_history
      WHERE f = "Currency"
      AND "date" <= _r.date AND "date" > _r.date - INTERVAL '1 HOUR' * "Interval";
      IF _train_period > 0 THEN
        _train_period = _train_period - 1;
      ELSE
        _kline_set.date = _r.date;
        _kline_set.open = _open;
        _kline_set.close = _r.close;
        _kline_set.high = _high;
        _kline_set.low = _low;
        _kline_set.volume = _volume;
        _add = true;
      END IF;
      _open = _r.close; 
      IF _add THEN
        RETURN NEXT _kline_set;
      END IF;
    END;
  END LOOP;
  RETURN;
END;
$$;

CREATE OR REPLACE FUNCTION get_kline_day(
  "Currency" varchar,
  "Ending" timestamp,
  "Interval" integer, -- in number of days
  "NumberOfRecords" integer
)
RETURNS SETOF kline_set
LANGUAGE plpgsql AS $$
DECLARE
  _r price_index_history%rowtype;
  _open numeric := 0;
  _train integer;
  _train_period integer := 2;
  _kline_set kline_set;
BEGIN
  _train = "NumberOfRecords" + 2;
  FOR _r IN
    SELECT * FROM price_index_history 
    WHERE f = "Currency" 
    AND "date" <= "Ending" 
    AND "date" > "Ending" - INTERVAL '1 DAY' * "Interval" * ("NumberOfRecords" + 2)
    AND DATE_PART('day', date)::INTEGER % "Interval" = 0 
    AND DATE_PART('hour', date)::INTEGER = 0
    AND DATE_PART('minute', date)::INTEGER = 0
    ORDER BY DATE ASC LIMIT _train -- have to do asc here because of the way close data is generated.
  LOOP
    DECLARE
      _high numeric := 0;
      _low numeric := 0;
      _volume numeric := 0;
      _add boolean := false;
    BEGIN
      SELECT MAX(high), MIN(low), SUM(volume) INTO _high, _low, _volume FROM price_index_history
      WHERE f = "Currency"
      AND "date" <= _r.date AND "date" > _r.date - INTERVAL '1 DAY' * "Interval";
      IF _train_period > 0 THEN
        _train_period = _train_period - 1;
      ELSE
        _kline_set.date = _r.date;
        _kline_set.open = _open;
        _kline_set.close = _r.close;
        _kline_set.high = _high;
        _kline_set.low = _low;
        _kline_set.volume = _volume;
        _add = true;
      END IF;
      _open = _r.close; 
      IF _add THEN
        RETURN NEXT _kline_set;
      END IF;
    END;
  END LOOP;
  RETURN;
END;
$$;
