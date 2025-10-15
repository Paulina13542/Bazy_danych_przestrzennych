CREATE SCHEMA IF NOT EXISTS ksiegowosc;
SET search_path TO ksiegowosc, public;

CREATE TABLE pracownicy (
  id_pracownika INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  imie         TEXT        NOT NULL,
  nazwisko     TEXT        NOT NULL,
  adres        TEXT,
  telefon      TEXT,
  CONSTRAINT prac_unique UNIQUE (imie, nazwisko, telefon)
);

CREATE TABLE godziny (
  id_godziny     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  data           DATE         NOT NULL,
  liczba_godzin  NUMERIC(5,2) NOT NULL CHECK (liczba_godzin >= 0),
  id_pracownika  INTEGER      NOT NULL REFERENCES pracownicy(id_pracownika) ON DELETE CASCADE
);

CREATE TABLE pensja (
  id_pensji   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  stanowisko  TEXT           NOT NULL,
  kwota       NUMERIC(10,2)  NOT NULL CHECK (kwota > 0)
);

CREATE TABLE premia (
  id_premii  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  rodzaj     TEXT           NOT NULL,
  kwota      NUMERIC(10,2)  NOT NULL CHECK (kwota >= 0)
);

CREATE TABLE wynagrodzenie (
  id_wynagrodzenia INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  data             DATE        NOT NULL,
  id_pracownika    INTEGER     NOT NULL REFERENCES pracownicy(id_pracownika) ON DELETE CASCADE,
  id_godziny       INTEGER         REFERENCES godziny(id_godziny) ON DELETE SET NULL,
  id_pensji        INTEGER     NOT NULL REFERENCES pensja(id_pensji),
  id_premii        INTEGER         REFERENCES premia(id_premii)
);

INSERT INTO pracownicy (imie, nazwisko, adres, telefon) VALUES
('Jan',      'Nowak',        'ul. Klonowa 1, Warszawa',    '+48 600000001'),
('Julia',    'Kowalska',     'ul. Lipowa 2, Warszawa',     '+48 600000002'),
('Jakub',    'Wiśniewski',   'ul. Brzozowa 3, Kraków',     '+48 600000003'),
('Anna',     'Zielińska',    'ul. Dębowa 4, Gdańsk',       '+48 600000004'),
('Joanna',   'Lewandowska',  'ul. Topolowa 5, Wrocław',    '+48 600000005'),
('Michał',   'Wójcik',       'ul. Jesionowa 6, Poznań',    '+48 600000006'),
('Piotr',    'Kamiński',     'ul. Sosnowa 7, Łódź',        '+48 600000007'),
('Kinga',    'Jankowska',    'ul. Akacjowa 8, Szczecin',   '+48 600000008'),
('Justyna',  'Nowicka',      'ul. Bukowa 9, Lublin',       '+48 600000009'),
('Krzysztof','Szymański',    'ul. Graniczna 10, Białystok','+48 600000010');

INSERT INTO pensja (stanowisko, kwota) VALUES
('stażysta',        1000.00),
('młodszy asystent',1200.00),
('asystent',        1800.00),
('analityk',        2500.00),
('programista',     3200.00),
('starszy analityk',3500.00),
('kierownik',       4200.00),
('specjalista',     2800.00),
('księgowy',        2300.00),
('architekt',       5000.00);

INSERT INTO premia (rodzaj, kwota) VALUES
('brak',        0.00),
('frekwencyjna',200.00),
('uznaniowa',   500.00),
('projektowa',  800.00),
('świąteczna',  300.00),
('sprzedażowa', 600.00),
('roczna',     1200.00),
('stażowa',     150.00),
('bezpieczeństwo',250.00),
('zyskowa',     700.00);

INSERT INTO godziny (data, liczba_godzin, id_pracownika) VALUES
('2025-09-01', 8.0, 1),
('2025-09-02', 8.5, 1),
('2025-09-03', 7.5, 2),
('2025-09-04', 9.0, 3),
('2025-09-05', 8.0, 4),
('2025-09-06', 10.0,5),
('2025-09-07', 6.0, 6),
('2025-09-08', 8.0, 7),
('2025-09-09', 9.5, 8),
('2025-09-10', 7.0, 9);

INSERT INTO wynagrodzenie (data, id_pracownika, id_godziny, id_pensji, id_premii) VALUES
('2025-09-30', 1,  1, 4,  2),
('2025-09-30', 2,  3, 5,  NULL),
('2025-09-30', 3,  4, 3,  1),
('2025-09-30', 4,  5, 8,  3),
('2025-09-30', 5,  6, 6,  NULL),
('2025-09-30', 6,  7, 2,  5),
('2025-09-30', 7,  8, 9,  1),
('2025-09-30', 8,  9, 7,  NULL),
('2025-09-30', 9, 10, 1,  NULL),
('2025-09-30',10,  2,10,  4);
COMMENT ON TABLE pracownicy IS 'Pracownicy małej firmy (dane kontaktowe).';
COMMENT ON COLUMN pracownicy.id_pracownika IS 'Klucz główny pracownika.';
COMMENT ON COLUMN pracownicy.telefon IS 'Przechowywany jako tekst (formaty międzynarodowe).';

COMMENT ON TABLE godziny IS 'Ewidencja przepracowanych godzin danego dnia.';
COMMENT ON COLUMN godziny.liczba_godzin IS 'Liczba godzin pracy w danym dniu.';

COMMENT ON TABLE pensja IS 'Tabela stawek pensji brutto wg stanowiska.';
COMMENT ON COLUMN pensja.kwota IS 'Miesięczna kwota pensji brutto.';

COMMENT ON TABLE premia IS 'Tabela premii (rodzaj oraz kwota).';

COMMENT ON TABLE wynagrodzenie IS 'Wypłaty miesięczne: odniesienia do pensji, premii i ewidencji godzin.';
COMMENT ON COLUMN wynagrodzenie.id_premii IS 'Może być NULL, gdy brak premii.';