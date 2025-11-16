DROP TABLE IF EXISTS obiekty;

CREATE TABLE obiekty (
    id    serial PRIMARY KEY,
    nazwa text,
    geom  geometry
);

-- 1a) obiekt1 – COMPOUNDCURVE (odcinki + dwa łuki)
INSERT INTO obiekty (nazwa, geom) VALUES (
  'obiekt1',
  ST_GeomFromEWKT(
    'SRID=0;
     COMPOUNDCURVE(
       (0 1, 1 1),
       CIRCULARSTRING(1 1, 2 0, 3 1),
       CIRCULARSTRING(3 1, 4 2, 5 1),
       (5 1, 6 1)
     )'
  )
);

-- 1b) obiekt2 – CURVEPOLYGON
INSERT INTO obiekty (nazwa, geom) VALUES (
  'obiekt2',
  ST_GeomFromEWKT(
    'SRID=0;
     CURVEPOLYGON(
       COMPOUNDCURVE(
         (10 2, 10 6, 14 6),
         CIRCULARSTRING(14 6, 16 4, 14 2),
         CIRCULARSTRING(14 2, 12 0, 10 2)
       ),
       CIRCULARSTRING(11 2, 12 3, 13 2, 12 1, 11 2)
     )'
  )
);

-- 1c) obiekt3 – trójkąt (POLYGON)
INSERT INTO obiekty (nazwa, geom) VALUES (
  'obiekt3',
  ST_GeomFromEWKT(
    'SRID=0;
     POLYGON((7 15, 10 17, 12 13, 7 15))'
  )
);

-- 1d) obiekt4 – łamana (LINESTRING)
INSERT INTO obiekty (nazwa, geom) VALUES (
  'obiekt4',
  ST_GeomFromEWKT(
    'SRID=0;
     LINESTRING(
       20 20,
       20.5 19.5,
       22 19,
       26 21,
       25 22,
       27 24,
       25 25
     )'
  )
);

-- 1e) obiekt5 – dwa punkty 3D (MULTIPOINT Z)
INSERT INTO obiekty (nazwa, geom) VALUES (
  'obiekt5',
  ST_GeomFromEWKT(
    'SRID=0;
     MULTIPOINT Z(
       (30 30 59),
       (38 32 234)
     )'
  )
);

-- 1f) obiekt6 – kolekcja: linia + punkt (GEOMETRYCOLLECTION)
INSERT INTO obiekty (nazwa, geom) VALUES (
  'obiekt6',
  ST_GeomFromEWKT(
    'SRID=0;
     GEOMETRYCOLLECTION(
       LINESTRING(1 1, 3 2),
       POINT(4 2)
     )'
  )
);

-- (kontrola, czy wszystko jest)
SELECT id, nazwa, ST_GeometryType(geom) AS typ
FROM obiekty
ORDER BY id;

SELECT
  ST_Area(
    ST_Buffer(
      ST_ShortestLine(o3.geom, o4.geom),
      5
    )
  ) AS pole_bufora_r5
FROM obiekty o3, obiekty o4
WHERE o3.nazwa = 'obiekt3'
  AND o4.nazwa = 'obiekt4';


-- 3a) typ PRZED
SELECT nazwa, ST_GeometryType(geom)
FROM obiekty
WHERE nazwa = 'obiekt4';

-- 3b) zamiana: domykamy linię (dodajemy punkt startowy na końcu)
--     i tworzymy poligon
UPDATE obiekty
SET geom = ST_MakePolygon(
             ST_AddPoint(geom, ST_StartPoint(geom))
          )
WHERE nazwa = 'obiekt4';

-- 3c) typ PO
SELECT nazwa, ST_GeometryType(geom)
FROM obiekty
WHERE nazwa = 'obiekt4';

INSERT INTO obiekty (nazwa, geom)
SELECT
  'obiekt7',
  ST_Collect(o3.geom, o4.geom)
FROM obiekty o3, obiekty o4
WHERE o3.nazwa = 'obiekt3'
  AND o4.nazwa = 'obiekt4';

-- (opcjonalnie: kontrola typu)
SELECT nazwa, ST_GeometryType(geom)
FROM obiekty
WHERE nazwa = 'obiekt7';

SELECT
  SUM( ST_Area( ST_Buffer(geom, 5) ) ) AS suma_pol_buforow_r5
FROM obiekty
WHERE NOT ST_HasArc(geom);

SELECT id, nazwa, ST_AsText(geom)
FROM obiekty;
