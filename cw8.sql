-- 1) Wycięcie rastrowej mapy 250k do granic parku (id=1)
DROP TABLE IF EXISTS uk_lake_district;
CREATE TABLE uk_lake_district AS
SELECT
    ST_Clip(u.rast, np.geom, TRUE) AS rast
FROM
    uk_250k_2 u
JOIN
    national_parks_cliped np
ON
    np.id = 1
    AND ST_Intersects(u.rast, np.geom);


-- 2) Clip pasma GREEN Sentinel do parku (dopasowanie SRID geometrii do rastra)
DROP TABLE IF EXISTS sentinel_green_clip;
CREATE TABLE sentinel_green_clip AS
SELECT
    ST_Clip(g.rast, ST_Transform(n.geom, ST_SRID(g.rast)), TRUE) AS rast
FROM
    sentinel_green g
JOIN
    national_parks n
ON
    n.id = 1
    AND ST_Intersects(g.rast, ST_Transform(n.geom, ST_SRID(g.rast)));

SELECT AddRasterConstraints('sentinel_green_clip', 'rast');
DROP INDEX IF EXISTS sentinel_green_clip_gix;
CREATE INDEX sentinel_green_clip_gix
    ON sentinel_green_clip
    USING GIST (ST_ConvexHull(rast));


-- 3) Clip pasma NIR Sentinel do parku
DROP TABLE IF EXISTS sentinel_nir_clip;
CREATE TABLE sentinel_nir_clip AS
SELECT
    ST_Clip(nir.rast, ST_Transform(p.geom, ST_SRID(nir.rast)), TRUE) AS rast
FROM
    sentinel_nir nir
JOIN
    national_parks p
ON
    p.id = 1
    AND ST_Intersects(nir.rast, ST_Transform(p.geom, ST_SRID(nir.rast)));

SELECT AddRasterConstraints('sentinel_nir_clip', 'rast');
DROP INDEX IF EXISTS sentinel_nir_clip_gix;
CREATE INDEX sentinel_nir_clip_gix
    ON sentinel_nir_clip
    USING GIST (ST_ConvexHull(rast));


-- 4) NDWI = (GREEN - NIR) / (GREEN + NIR), liczony piksel po pikselu
DROP TABLE IF EXISTS lake_district_ndwi_v2;
CREATE TABLE lake_district_ndwi_v2 AS
SELECT
    ST_SetSRID(
        ST_MapAlgebra(
            gr.rast,
            nr.rast,
            '(([rast1] - [rast2]) / NULLIF(([rast1] + [rast2]), 0))::float'
        ),
        ST_SRID(gr.rast)
    ) AS rast
FROM
    sentinel_green_clip gr
JOIN
    sentinel_nir_clip  nr
ON
    ST_Intersects(gr.rast, nr.rast);

SELECT AddRasterConstraints('lake_district_ndwi_v2', 'rast');

-- Szybki sanity check: ile kafli wyszło
SELECT COUNT(*) FROM lake_district_ndwi_v2;
