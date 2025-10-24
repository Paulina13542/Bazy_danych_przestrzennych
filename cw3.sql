-- 1. nowe lub wyremontowane budynki
CREATE TABLE new_or_renovated_buildings AS
SELECT b2019.*
FROM "T2019_KAR_BUILDINGS" b2019
LEFT JOIN "T2018_KAR_BUILDINGS" b2018
ON ST_Intersects(b2019.geom, b2018.geom)
WHERE b2018.geom IS NULL;

-- 2. nowe POI w promieniu 500 m od nowych budynków
SELECT p.category, COUNT(*) AS liczba_nowych_poi
FROM "T2019_KAR_POI_TABLE" p
WHERE NOT EXISTS (
    SELECT 1 FROM "T2018_KAR_POI_TABLE" old
    WHERE ST_Equals(p.geom, old.geom)
)
AND EXISTS (
    SELECT 1 FROM new_or_renovated_buildings b
    WHERE ST_DWithin(p.geom, b.geom, 0.005)
)
GROUP BY p.category
ORDER BY liczba_nowych_poi DESC;

-- 3. tabela streets_reprojected w układzie Cassini
CREATE TABLE streets_reprojected AS
SELECT *, ST_Transform(geom, 3068) AS geom_3068
FROM "T2019_KAR_STREETS";

-- 4. utworzenie tabeli input_points
CREATE TABLE input_points (
  id SERIAL PRIMARY KEY,
  geom geometry(Point, 4326)
);

INSERT INTO input_points (geom)
VALUES
  (ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
  (ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));

-- 5. aktualizacja punktów do układu Cassini
UPDATE input_points
SET geom = ST_Transform(geom, 3068);

-- 6. skrzyżowania w odległości 200 m od linii z input_points
CREATE TABLE near_intersections AS
SELECT n.*
FROM "T2019_KAR_STREET_NODE" n
WHERE ST_DWithin(
  n.geom,
  (SELECT ST_MakeLine(geom ORDER BY id) FROM input_points),
  0.002
);

-- 7. liczba sklepów sportowych 300 m od parków
SELECT COUNT(*) AS sklepy_sportowe_w_poblizu_parkow
FROM "T2019_KAR_POI_TABLE" p
JOIN "T2019_KAR_LAND_USE_A" l
ON ST_DWithin(p.geom, l.geom, 0.003)
WHERE p.category = 'Sporting Goods Store';

-- 8. punkty przecięcia torów i cieków
CREATE TABLE "T2019_KAR_BRIDGES" AS
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM "T2019_KAR_RAILWAYS" r
JOIN "T2019_KAR_WATER_LINES" w
ON ST_Intersects(r.geom, w.geom);
