SET search_path = paulina, rasters, vectors, public;

DROP TABLE IF EXISTS paulina.intersects CASCADE;
CREATE TABLE paulina.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom)
  AND b.municipality ILIKE 'porto';
ALTER TABLE paulina.intersects ADD COLUMN rid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'intersects'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.clip CASCADE;
CREATE TABLE paulina.clip AS
SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
FROM rasters.dem AS a
JOIN vectors.porto_parishes AS b ON ST_Intersects(b.geom, a.rast)
WHERE b.municipality ILIKE 'porto';
ALTER TABLE paulina.clip ADD COLUMN id SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'clip'::name,'rast'::name);

DROP TABLE IF EXISTS paulina."union" CASCADE;
CREATE TABLE paulina."union" AS SELECT ST_Union(rast) AS rast FROM paulina.clip;
ALTER TABLE paulina."union" ADD COLUMN id SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'union'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.intersection CASCADE;
CREATE TABLE paulina.intersection AS 
SELECT a.rid, (ST_Intersection(b.geom, a.rast)).geom,
       (ST_Intersection(b.geom, a.rast)).val
FROM rasters.landsat8 AS a
JOIN vectors.porto_parishes AS b ON ST_Intersects(b.geom, a.rast)
WHERE b.parish ILIKE 'paranhos';
ALTER TABLE paulina.intersection ADD COLUMN gid SERIAL PRIMARY KEY;

DROP TABLE IF EXISTS paulina.dumppolygons CASCADE;
CREATE TABLE paulina.dumppolygons AS
SELECT a.rid,
       (ST_DumpAsPolygons(ST_Clip(a.rast, b.geom))).geom,
       (ST_DumpAsPolygons(ST_Clip(a.rast, b.geom))).val
FROM rasters.landsat8 AS a
JOIN vectors.porto_parishes AS b ON ST_Intersects(b.geom, a.rast)
WHERE b.parish ILIKE 'paranhos';
ALTER TABLE paulina.dumppolygons ADD COLUMN gid SERIAL PRIMARY KEY;

DROP TABLE IF EXISTS paulina.paranhos_dem CASCADE;
CREATE TABLE paulina.paranhos_dem AS
SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
FROM rasters.dem AS a
JOIN vectors.porto_parishes AS b ON ST_Intersects(b.geom, a.rast)
WHERE b.parish ILIKE 'paranhos';
ALTER TABLE paulina.paranhos_dem ADD COLUMN gid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'paranhos_dem'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.paranhos_slope CASCADE;
CREATE TABLE paulina.paranhos_slope AS
SELECT a.rid, ST_Slope(a.rast, 1, '32BF', 'PERCENTAGE') AS rast
FROM paulina.paranhos_dem AS a;
ALTER TABLE paulina.paranhos_slope ADD COLUMN gid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'paranhos_slope'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.paranhos_slope_reclass CASCADE;
CREATE TABLE paulina.paranhos_slope_reclass AS
SELECT a.rid,
       ST_Reclass(a.rast, 1, ']0-15]:1, (15-30]:2, (30-9999:3','32BF',0) AS rast
FROM paulina.paranhos_slope AS a;
ALTER TABLE paulina.paranhos_slope_reclass ADD COLUMN gid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'paranhos_slope_reclass'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.tpi30 CASCADE;
CREATE TABLE paulina.tpi30 AS SELECT ST_TPI(a.rast, 1) AS rast FROM rasters.dem AS a;
ALTER TABLE paulina.tpi30 ADD COLUMN rid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'tpi30'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.tpi30_porto CASCADE;
CREATE TABLE paulina.tpi30_porto AS
SELECT ST_TPI(a.rast, 1) AS rast
FROM rasters.dem AS a
JOIN vectors.porto_parishes AS b ON ST_Intersects(a.rast, b.geom)
WHERE b.municipality ILIKE 'porto';
ALTER TABLE paulina.tpi30_porto ADD COLUMN rid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'tpi30_porto'::name,'rast'::name);

DROP TABLE IF EXISTS paulina.porto_ndvi CASCADE;
CREATE TABLE paulina.porto_ndvi AS 
WITH r AS (
  SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
  FROM rasters.landsat8 AS a
  JOIN vectors.porto_parishes AS b ON ST_Intersects(b.geom, a.rast)
  WHERE b.municipality ILIKE 'porto'
)
SELECT r.rid,
       ST_MapAlgebra(r.rast,1,r.rast,4,
         '([rast2.val]-[rast1.val])/([rast2.val]+[rast1.val])::float','32BF') AS rast
FROM r;
ALTER TABLE paulina.porto_ndvi ADD COLUMN gid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'porto_ndvi'::name,'rast'::name);

CREATE OR REPLACE FUNCTION paulina.ndvi(
  value double precision[][][], pos integer[][], VARIADIC userargs text[]
) RETURNS double precision AS $$
BEGIN
  RETURN (value[2][1][1] - value[1][1][1]) /
         (value[2][1][1] + value[1][1][1]);
END; $$ LANGUAGE plpgsql IMMUTABLE;

DROP TABLE IF EXISTS paulina.porto_ndvi2 CASCADE;
CREATE TABLE paulina.porto_ndvi2 AS 
WITH r AS (
  SELECT a.rid, ST_Clip(a.rast, b.geom, true) AS rast
  FROM rasters.landsat8 AS a
  JOIN vectors.porto_parishes AS b ON ST_Intersects(b.geom, a.rast)
  WHERE b.municipality ILIKE 'porto'
)
SELECT r.rid,
       ST_MapAlgebra(
         r.rast,
         ARRAY[1,4],
         'paulina.ndvi(double precision[], integer[], text[])'::regprocedure,
         '32BF'
       ) AS rast
FROM r;
ALTER TABLE paulina.porto_ndvi2 ADD COLUMN gid SERIAL PRIMARY KEY;
SELECT AddRasterConstraints('paulina'::name,'porto_ndvi2'::name,'rast'::name);
