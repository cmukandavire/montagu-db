-- NOTE for review:
--
-- does it makes sense to prefix these tables with country_ or not?
-- check null ness for everything
-- everything that needs to be an enum table done
-- no "data" in column names (e.g., thing_2008, thing_yf, etc)
-- some of the not-null constraints need to be relaxed until we have the data import done - this needs writing out as a second import.


CREATE TABLE gavi_region (
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (id)
);
COMMENT ON TABLE gavi_region IS
  'include four types of gavi region interested by gavi donors';

CREATE TABLE country_disease_endemic (
  id SERIAL,
  touchstone TEXT NOT NULL,
  country TEXT  NOT NULL,
  disease TEXT  NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (touchstone) REFERENCES touchstone(id),
  FOREIGN KEY (country) REFERENCES country(id),
  FOREIGN KEY (disease) REFERENCES disease(id)
);

CREATE TABLE country_fragility (
  id SERIAL,
  touchstone TEXT NOT NULL,
  country TEXT NOT NULL,
  year INTEGER NOT NULL,
  is_fragile BOOLEAN NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (touchstone) REFERENCES touchstone(id),
  FOREIGN KEY (country) REFERENCES country(id)
);

CREATE TABLE cofinance_status (
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE country_cofinance (
  id SERIAL,
  touchstone TEXT NOT NULL,
  country TEXT NOT NULL,
  year INTEGER NOT NULL,
  cofinance_status text NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (touchstone) REFERENCES touchstone(id),
  FOREIGN KEY (country) REFERENCES country(id),
  FOREIGN KEY (cofinance_status) REFERENCES cofinance_status(id)
);

CREATE TABLE worldbank_status (
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (id)
);
COMMENT ON TABLE worldbank_status IS
  'Country development status according to the worldbank';


CREATE TABLE country_worldbank_status (
  id  SERIAL,
  touchstone TEXT NOT NULL,
  country TEXT NOT NULL,
  year INTEGER NOT NULL,
  worldbank_status TEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (touchstone) REFERENCES touchstone(id),
  FOREIGN KEY (country) REFERENCES country(id),
  FOREIGN KEY (worldbank_status) REFERENCES worldbank_status(id),
  UNIQUE (touchstone, country, year)
);

CREATE TABLE francophone_status (
  id TEXT,
  PRIMARY KEY (id)
);
COMMENT ON TABLE francophone_status IS
  'Status within the Organisation internationale de la Francophonie';

CREATE TABLE vxdel_segment (
  id TEXT,
  PRIMARY KEY (id)
);
COMMENT ON TABLE vxdel_segment IS
  'Status within BMGF vxdel country classifiecation';

ALTER TABLE country_metadata
  ADD COLUMN francophone TEXT,
  ADD COLUMN vxdel_segment TEXT,
  ADD COLUMN pine_5 BOOLEAN,
  ADD COLUMN dove94 BOOLEAN,
  ADD COLUMN gavi68 BOOLEAN,
  ADD COLUMN gavi72 BOOLEAN,
  ADD COLUMN gavi77 BOOLEAN,
  ADD COLUMN dove96 BOOLEAN,
  ADD COLUMN gavi_region TEXT,
  ADD COLUMN gavi_pef_tier INTEGER,
  ADD FOREIGN KEY (gavi_region) REFERENCES gavi_region(id),
  ADD FOREIGN KEY (francophone) REFERENCES francophone_status(id),
  ADD FOREIGN KEY (vxdel_segment) REFERENCES vxdel_segment(id);

COMMENT ON COLUMN country_metadata.francophone IS
  '28 Gavi-supported French-speaking countries of interest to Gavi donors + 1 associated member + 4 observer counrties';

COMMENT ON COLUMN country_metadata.vxdel_segment IS
  'An internal grouping as used by BMFG to stratify countries';

COMMENT ON COLUMN country_metadata.gavi_pef_tier IS
  'Gavi Partners engagement framework; Tier 1, 2 or 3 (stored as integer). NULL values indicate "Not PEF"';

