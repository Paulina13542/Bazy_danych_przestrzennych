CREATE TABLE buildings (
  id   serial PRIMARY KEY,
  name text UNIQUE,
  geom geometry(Polygon)
);

CREATE TABLE roads (
  id   serial PRIMARY KEY,
  name text UNIQUE,
  geom geometry(LineString)
);

CREATE TABLE poi (
  id   serial PRIMARY KEY,
  name text UNIQUE,
  geom geometry(Point)
);

INSERT INTO buildings (name, geom) VALUES
('BuildingA', ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))')),
('BuildingB', ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))')),
('BuildingC', ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))')),
('BuildingD', ST_GeomFromText('POLYGON((9 8, 10 8, 10 9, 9 9, 9 8))')),
('BuildingF', ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))'));

INSERT INTO roads (name, geom) VALUES
('RoadX', ST_GeomFromText('LINESTRING(8 4.5, 12 4.5)')),
('RoadY', ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'));

INSERT INTO poi (name, geom) VALUES
('G', ST_GeomFromText('POINT(1.3 3.5)')),
('H', ST_GeomFromText('POINT(5.5 1.5)')),
('I', ST_GeomFromText('POINT(9.5 6)')),
('J', ST_GeomFromText('POINT(6.5 6)')),
('K', ST_GeomFromText('POINT(6 9.5)'));



SELECT SUM(ST_Length(geom)) AS total_roads_length FROM roads;

SELECT ST_AsText(geom)      AS wkt,
       ST_Area(geom)        AS area,
       ST_Perimeter(geom)   AS perimeter
FROM buildings
WHERE name = 'BuildingA';

SELECT name, ST_Area(geom) AS area
FROM buildings
ORDER BY name;

SELECT name, ST_Perimeter(geom) AS perimeter
FROM buildings
ORDER BY ST_Area(geom) DESC
LIMIT 2;

SELECT ST_Distance(b.geom, p.geom) AS dist
FROM buildings b
JOIN poi p ON p.name = 'K'
WHERE b.name = 'BuildingC';

SELECT ST_Area(
         ST_Difference(c.geom, ST_Buffer(b.geom, 0.5))
       ) AS area_farther_than_0_5
FROM buildings c
JOIN buildings b ON b.name = 'BuildingB'
WHERE c.name = 'BuildingC';

SELECT b.name
FROM buildings b
JOIN roads r ON r.name = 'RoadX'
WHERE ST_Y(ST_Centroid(b.geom)) > ST_Y(ST_StartPoint(r.geom));

SELECT ST_Area(
         ST_SymDifference(
           (SELECT geom FROM buildings WHERE name='BuildingC'),
           ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')
         )
       ) AS symdiff_area;



