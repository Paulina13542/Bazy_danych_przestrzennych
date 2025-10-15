SELECT id_pracownika, nazwisko
FROM ksiegowosc.pracownicy;

SELECT DISTINCT w.id_pracownika
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
WHERE p.kwota > 1000;

SELECT DISTINCT w.id_pracownika
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
WHERE w.id_premii IS NULL
  AND p.kwota > 2000;

SELECT *
FROM ksiegowosc.pracownicy
WHERE imie ILIKE 'J%';

SELECT *
FROM ksiegowosc.pracownicy
WHERE nazwisko ILIKE '%n%'
  AND imie ILIKE '%a';

WITH suma AS (
  SELECT g.id_pracownika,
         SUM(g.liczba_godzin) AS godziny_mies
  FROM ksiegowosc.godziny g
  WHERE date_trunc('month', g.data) = DATE '2025-09-01'
  GROUP BY g.id_pracownika
)
SELECT pr.imie, pr.nazwisko,
       GREATEST(COALESCE(s.godziny_mies,0) - 160, 0) AS nadgodziny
FROM ksiegowosc.pracownicy pr
LEFT JOIN suma s ON s.id_pracownika = pr.id_pracownika
ORDER BY pr.nazwisko, pr.imie;

SELECT DISTINCT pr.imie, pr.nazwisko
FROM ksiegowosc.pracownicy pr
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika = pr.id_pracownika
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
WHERE p.kwota BETWEEN 1500 AND 3000
ORDER BY pr.nazwisko, pr.imie;

WITH suma AS (
  SELECT g.id_pracownika,
         SUM(g.liczba_godzin) AS godziny_mies
  FROM ksiegowosc.godziny g
  WHERE date_trunc('month', g.data) = DATE '2025-09-01'
  GROUP BY g.id_pracownika
)
SELECT DISTINCT pr.imie, pr.nazwisko
FROM ksiegowosc.pracownicy pr
JOIN suma s ON s.id_pracownika = pr.id_pracownika
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika = pr.id_pracownika
WHERE s.godziny_mies > 160
  AND w.id_premii IS NULL
ORDER BY pr.nazwisko, pr.imie;

SELECT pr.imie, pr.nazwisko, p.kwota AS pensja
FROM ksiegowosc.pracownicy pr
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika = pr.id_pracownika
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
ORDER BY p.kwota ASC, pr.nazwisko, pr.imie;

SELECT pr.imie, pr.nazwisko, p.kwota AS pensja, COALESCE(pm.kwota,0) AS premia
FROM ksiegowosc.pracownicy pr
JOIN ksiegowosc.wynagrodzenie w ON w.id_pracownika = pr.id_pracownika
JOIN ksiegowosc.pensja p  ON p.id_pensji = w.id_pensji
LEFT JOIN ksiegowosc.premia pm ON pm.id_premii = w.id_premii
ORDER BY p.kwota DESC, COALESCE(pm.kwota,0) DESC, pr.nazwisko, pr.imie;

SELECT p.stanowisko, COUNT(DISTINCT w.id_pracownika) AS liczba_pracownikow
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
GROUP BY p.stanowisko
ORDER BY liczba_pracownikow DESC, p.stanowisko;

SELECT
  p.stanowisko,
  AVG(p.kwota) AS srednia,
  MIN(p.kwota) AS min,
  MAX(p.kwota) AS max
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
WHERE p.stanowisko = 'kierownik'
GROUP BY p.stanowisko;

SELECT SUM(p.kwota + COALESCE(pm.kwota,0)) AS suma_wynagrodzen
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p  ON p.id_pensji = w.id_pensji
LEFT JOIN ksiegowosc.premia pm ON pm.id_premii = w.id_premii;

SELECT p.stanowisko,
       SUM(p.kwota + COALESCE(pm.kwota,0)) AS suma_stanowisko
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p  ON p.id_pensji = w.id_pensji
LEFT JOIN ksiegowosc.premia pm ON pm.id_premii = w.id_premii
GROUP BY p.stanowisko
ORDER BY suma_stanowisko DESC;

SELECT p.stanowisko,
       COUNT(w.id_premii) AS liczba_premii
FROM ksiegowosc.wynagrodzenie w
JOIN ksiegowosc.pensja p ON p.id_pensji = w.id_pensji
GROUP BY p.stanowisko
ORDER BY liczba_premii DESC, p.stanowisko;

DELETE FROM ksiegowosc.pracownicy pr
USING ksiegowosc.wynagrodzenie w, ksiegowosc.pensja p
WHERE w.id_pracownika = pr.id_pracownika
  AND p.id_pensji = w.id_pensji
  AND p.kwota < 1200;