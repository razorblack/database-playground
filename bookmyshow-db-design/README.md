# BookMyShow Database Design

## Problem Statement

BookMyShow is a ticketing platform where users can book tickets for movie shows. The App UI works like this:
- For a given theatre, users can see the next 7 dates
- When a date is selected, all shows running in that theatre are displayed along with show timings

**Task:**
1. Design the database schema - list all entities, attributes, and table structures
2. Ensure tables follow normalization rules (1NF, 2NF, 3NF, BCNF)
3. Write SQL queries to create tables with sample data
4. Write a query to list all shows on a given date at a given theatre with their timings

---

## Breaking Down the Problem

Before jumping into tables, let me think about what's actually happening in the real world...

When I open BookMyShow and select a theatre:
- I see dates (next 7 days)
- Each date has multiple shows
- Each show is a movie playing at a specific time
- A theatre has multiple screens/halls
- Same movie can run on different screens at different times

So the key entities I can identify:
1. **Theatre** - The cinema hall complex (PVR, INOX, etc.)
2. **Screen** - Individual screens within a theatre (Screen 1, Screen 2, etc.)
3. **Movie** - The films that are playing
4. **Show** - A specific screening of a movie on a screen at a particular date and time

---

## Entity Analysis

### Theatre
What info do we need about a theatre?
- Unique identifier
- Name (PVR Phoenix, INOX Mantri, etc.)
- Location/Address
- City (for filtering)

### Screen
- Unique identifier  
- Which theatre it belongs to
- Screen number/name
- Seating capacity (might be useful)

### Movie
- Unique identifier
- Title
- Duration (to calculate show end times)
- Language
- Genre

### Show
This is the central entity connecting everything:
- Unique identifier
- Which movie
- Which screen (and through screen, which theatre)
- Date
- Start time
- Price (can vary by show timing - morning shows are cheaper!)

---

## Normalization Check

Let me verify the design follows normalization rules:

### 1NF (First Normal Form)
✅ All columns contain atomic values (no multi-valued attributes)
✅ Each row is unique (has primary key)
✅ No repeating groups

### 2NF (Second Normal Form)  
✅ Already in 1NF
✅ All non-key attributes are fully dependent on the primary key
- In `shows` table: movie_id, screen_id, show_date, show_time, price all depend entirely on show_id

### 3NF (Third Normal Form)
✅ Already in 2NF
✅ No transitive dependencies
- Theatre info is in its own table, not duplicated in screens
- Movie info is in its own table, not duplicated in shows

### BCNF (Boyce-Codd Normal Form)
✅ Already in 3NF
✅ For every functional dependency X → Y, X is a super key
- All our functional dependencies have primary keys as determinants

---

## Database Schema

### ER Diagram (Text Representation)

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│   THEATRE   │       │   SCREEN    │       │    MOVIE    │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ theatre_id  │──┐    │ screen_id   │       │ movie_id    │
│ name        │  │    │ theatre_id  │──┐    │ title       │
│ address     │  └───>│ screen_name │  │    │ duration_min│
│ city        │       │ capacity    │  │    │ language    │
└─────────────┘       └─────────────┘  │    │ genre       │
                            │          │    └─────────────┘
                            │          │           │
                            ▼          │           │
                      ┌─────────────┐  │           │
                      │    SHOW     │  │           │
                      ├─────────────┤  │           │
                      │ show_id     │  │           │
                      │ movie_id    │◄─┼───────────┘
                      │ screen_id   │◄─┘
                      │ show_date   │
                      │ show_time   │
                      │ price       │
                      └─────────────┘
```

### Tables Overview

| Table | Primary Key | Foreign Keys | Description |
|-------|-------------|--------------|-------------|
| theatres | theatre_id | - | Cinema complexes |
| screens | screen_id | theatre_id → theatres | Individual screens in a theatre |
| movies | movie_id | - | Movie information |
| shows | show_id | movie_id → movies, screen_id → screens | Scheduled screenings |

---

## Table Structures with Attributes

### 1. theatres

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| theatre_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| name | VARCHAR(100) | NOT NULL | Theatre name |
| address | VARCHAR(255) | NOT NULL | Full address |
| city | VARCHAR(50) | NOT NULL | City name |

### 2. screens

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| screen_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| theatre_id | INT | FOREIGN KEY, NOT NULL | Reference to theatre |
| screen_name | VARCHAR(50) | NOT NULL | Screen identifier (Screen 1, IMAX, etc.) |
| capacity | INT | NOT NULL | Total seats |

### 3. movies

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| movie_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| title | VARCHAR(150) | NOT NULL | Movie title |
| duration_min | INT | NOT NULL | Runtime in minutes |
| language | VARCHAR(30) | NOT NULL | Primary language |
| genre | VARCHAR(50) | | Movie genre |

### 4. shows

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| show_id | INT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| movie_id | INT | FOREIGN KEY, NOT NULL | Reference to movie |
| screen_id | INT | FOREIGN KEY, NOT NULL | Reference to screen |
| show_date | DATE | NOT NULL | Date of show |
| show_time | TIME | NOT NULL | Start time |
| price | DECIMAL(8,2) | NOT NULL | Ticket price |

---

## Sample Data

### theatres
| theatre_id | name | address | city |
|------------|------|---------|------|
| 1 | PVR Phoenix | Phoenix Marketcity, Whitefield | Bangalore |
| 2 | INOX Mantri Square | Mantri Square Mall, Malleshwaram | Bangalore |
| 3 | Cinepolis Orion | Orion Mall, Rajajinagar | Bangalore |

### screens
| screen_id | theatre_id | screen_name | capacity |
|-----------|------------|-------------|----------|
| 1 | 1 | Screen 1 | 150 |
| 2 | 1 | Screen 2 | 120 |
| 3 | 1 | IMAX | 300 |
| 4 | 2 | Audi 1 | 200 |
| 5 | 2 | Audi 2 | 180 |
| 6 | 3 | Screen 1 | 160 |

### movies
| movie_id | title | duration_min | language | genre |
|----------|-------|--------------|----------|-------|
| 1 | Pushpa 2: The Rule | 175 | Telugu | Action |
| 2 | Mufasa: The Lion King | 118 | English | Animation |
| 3 | Marco | 152 | Malayalam | Action |
| 4 | Baby John | 145 | Hindi | Action |

### shows
| show_id | movie_id | screen_id | show_date | show_time | price |
|---------|----------|-----------|-----------|-----------|-------|
| 1 | 1 | 1 | 2026-01-18 | 09:30:00 | 150.00 |
| 2 | 1 | 1 | 2026-01-18 | 14:00:00 | 200.00 |
| 3 | 1 | 1 | 2026-01-18 | 18:30:00 | 250.00 |
| 4 | 2 | 2 | 2026-01-18 | 10:00:00 | 180.00 |
| 5 | 2 | 2 | 2026-01-18 | 15:00:00 | 220.00 |
| 6 | 1 | 3 | 2026-01-18 | 11:00:00 | 400.00 |
| 7 | 3 | 4 | 2026-01-18 | 09:00:00 | 140.00 |
| 8 | 3 | 4 | 2026-01-18 | 13:30:00 | 190.00 |
| 9 | 4 | 5 | 2026-01-18 | 10:30:00 | 160.00 |
| 10 | 1 | 6 | 2026-01-19 | 12:00:00 | 200.00 |

---

## SQL Solutions

### Problem 1: Create Tables with Sample Data

See [schema.sql](./schema.sql) for the complete executable SQL.

```sql
-- Create Database
CREATE DATABASE IF NOT EXISTS bookmyshow;
USE bookmyshow;

-- Theatres table
CREATE TABLE theatres (
    theatre_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(50) NOT NULL
);

-- Screens table
CREATE TABLE screens (
    screen_id INT AUTO_INCREMENT PRIMARY KEY,
    theatre_id INT NOT NULL,
    screen_name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,
    FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id)
);

-- Movies table
CREATE TABLE movies (
    movie_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    duration_min INT NOT NULL,
    language VARCHAR(30) NOT NULL,
    genre VARCHAR(50)
);

-- Shows table
CREATE TABLE shows (
    show_id INT AUTO_INCREMENT PRIMARY KEY,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    show_date DATE NOT NULL,
    show_time TIME NOT NULL,
    price DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
);
```

### Problem 2: Query to List Shows at a Theatre on a Given Date

```sql
SELECT 
    m.title AS movie_name,
    s.screen_name,
    sh.show_time,
    sh.price
FROM shows sh
INNER JOIN movies m ON sh.movie_id = m.movie_id
INNER JOIN screens s ON sh.screen_id = s.screen_id
INNER JOIN theatres t ON s.theatre_id = t.theatre_id
WHERE t.theatre_id = 1  -- Replace with desired theatre_id
  AND sh.show_date = '2026-01-18'  -- Replace with desired date
ORDER BY sh.show_time;
```

**Sample Output for PVR Phoenix on 2026-01-18:**

| movie_name | screen_name | show_time | price |
|------------|-------------|-----------|-------|
| Pushpa 2: The Rule | Screen 1 | 09:30:00 | 150.00 |
| Mufasa: The Lion King | Screen 2 | 10:00:00 | 180.00 |
| Pushpa 2: The Rule | IMAX | 11:00:00 | 400.00 |
| Pushpa 2: The Rule | Screen 1 | 14:00:00 | 200.00 |
| Mufasa: The Lion King | Screen 2 | 15:00:00 | 220.00 |
| Pushpa 2: The Rule | Screen 1 | 18:30:00 | 250.00 |

---


