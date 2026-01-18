-- =====================================================
-- BookMyShow Database Schema
-- =====================================================

-- Create and use the database
CREATE DATABASE IF NOT EXISTS bookmyshow;
USE bookmyshow;

-- =====================================================
-- Drop existing tables (for re-running the script)
-- =====================================================
DROP TABLE IF EXISTS shows;
DROP TABLE IF EXISTS screens;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS theatres;

-- =====================================================
-- TABLE: theatres
-- Stores information about cinema complexes
-- =====================================================
CREATE TABLE theatres (
    theatre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- =====================================================
-- TABLE: screens
-- Individual screens within a theatre
-- =====================================================
CREATE TABLE screens (
    screen_id INT AUTO_INCREMENT PRIMARY KEY,
    theatre_id INT NOT NULL,
    screen_name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- TABLE: movies
-- Movie information
-- =====================================================
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    duration_min INT NOT NULL,
    language VARCHAR(30) NOT NULL,
    genre VARCHAR(50)
);

-- =====================================================
-- TABLE: shows
-- Scheduled movie screenings
-- Links movies to screens with date/time
-- =====================================================
CREATE TABLE shows (
    show_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    show_date DATE NOT NULL,
    show_time TIME NOT NULL,
    price DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Ensure same screen doesn't have overlapping shows
    UNIQUE KEY unique_show (screen_id, show_date, show_time)
);

-- =====================================================
-- SAMPLE DATA
-- =====================================================

-- Insert theatres
INSERT INTO theatres (name, address, city) VALUES
('PVR Phoenix', 'Phoenix Marketcity, Whitefield', 'Bangalore'),
('INOX Mantri Square', 'Mantri Square Mall, Malleshwaram', 'Bangalore'),
('Cinepolis Orion', 'Orion Mall, Rajajinagar', 'Bangalore');

-- Insert screens
INSERT INTO screens (theatre_id, screen_name, capacity) VALUES
(1, 'Screen 1', 150),
(1, 'Screen 2', 120),
(1, 'IMAX', 300),
(2, 'Audi 1', 200),
(2, 'Audi 2', 180),
(3, 'Screen 1', 160);

-- Insert movies
INSERT INTO movies (title, duration_min, language, genre) VALUES
('Pushpa 2: The Rule', 175, 'Telugu', 'Action'),
('Mufasa: The Lion King', 118, 'English', 'Animation'),
('Marco', 152, 'Malayalam', 'Action'),
('Baby John', 145, 'Hindi', 'Action');

-- Insert shows
INSERT INTO shows (movie_id, screen_id, show_date, show_time, price) VALUES
-- PVR Phoenix - Screen 1 (Pushpa 2)
(1, 1, '2026-01-18', '09:30:00', 150.00),
(1, 1, '2026-01-18', '14:00:00', 200.00),
(1, 1, '2026-01-18', '18:30:00', 250.00),
-- PVR Phoenix - Screen 2 (Mufasa)
(2, 2, '2026-01-18', '10:00:00', 180.00),
(2, 2, '2026-01-18', '15:00:00', 220.00),
-- PVR Phoenix - IMAX (Pushpa 2)
(1, 3, '2026-01-18', '11:00:00', 400.00),
(1, 3, '2026-01-18', '16:00:00', 450.00),
-- INOX Mantri - Audi 1 (Marco)
(3, 4, '2026-01-18', '09:00:00', 140.00),
(3, 4, '2026-01-18', '13:30:00', 190.00),
(3, 4, '2026-01-18', '18:00:00', 240.00),
-- INOX Mantri - Audi 2 (Baby John)
(4, 5, '2026-01-18', '10:30:00', 160.00),
(4, 5, '2026-01-18', '15:30:00', 200.00),
-- Cinepolis Orion (Pushpa 2)
(1, 6, '2026-01-19', '12:00:00', 200.00),
(1, 6, '2026-01-19', '17:00:00', 250.00),
-- Some shows for next day
(2, 1, '2026-01-19', '10:00:00', 180.00),
(3, 4, '2026-01-19', '11:00:00', 170.00);

-- =====================================================
-- PROBLEM 2 SOLUTION
-- List all shows on a given date at a given theatre
-- along with their respective show timings
-- =====================================================

-- Query: Shows at PVR Phoenix (theatre_id = 1) on 2026-01-18
SELECT 
    m.title AS movie_name,
    s.screen_name,
    sh.show_time,
    m.duration_min,
    m.language,
    sh.price
FROM shows sh
INNER JOIN movies m ON sh.movie_id = m.movie_id
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
WHERE t.theatre_id = 1
  AND sh.show_date = '2026-01-18'
ORDER BY sh.show_time;
