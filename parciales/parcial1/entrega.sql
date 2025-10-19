-- Creación de la base de datos y tablas
CREATE DATABASE IF NOT EXISTS parcial1_db;

USE parcial1_db;

CREATE TABLE IF NOT EXISTS animal_types (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS specializations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS veterinaries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  NIT VARCHAR(20) NOT NULL UNIQUE,
  address VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS owners (
  id INT AUTO_INCREMENT PRIMARY KEY,
  identification VARCHAR(20) NOT NULL UNIQUE,
  firstname VARCHAR(100) NOT NULL,
  lastname VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  address VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS home_visits (
  id INT AUTO_INCREMENT PRIMARY KEY,
  temperature DECIMAL(5, 2) NOT NULL,
  weight DECIMAL(5, 2) NOT NULL,
  respiratory_rate INT NOT NULL,
  heart_rate INT NOT NULL,
  mood TEXT,
  date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS pets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  eye_color VARCHAR(20) NOT NULL,
  height DECIMAL(5, 2),
  skin_tone ENUM('Black', 'White', 'Brown', 'Other'),
  type_id INT NOT NULL,
  owner_id INT NOT NULL,
  FOREIGN KEY (type_id) REFERENCES animal_types(id),
  FOREIGN KEY (owner_id) REFERENCES owners(id)
);

CREATE TABLE IF NOT EXISTS veterinarians (
  id INT AUTO_INCREMENT PRIMARY KEY,
  identification VARCHAR(20) NOT NULL UNIQUE,
  firstname VARCHAR(100) NOT NULL,
  lastname VARCHAR(100) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  professional_card VARCHAR(100) NOT NULL UNIQUE,
  veterinary_id INT NOT NULL,
  FOREIGN KEY (veterinary_id) REFERENCES veterinaries(id)
);

CREATE TABLE IF NOT EXISTS requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  home_visit_date DATE,
  pet_id INT NOT NULL,
  veterinarian_id INT NOT NULL,
  visit_id INT,
  FOREIGN KEY (pet_id) REFERENCES pets(id),
  FOREIGN KEY (veterinarian_id) REFERENCES veterinarians(id),
  FOREIGN KEY (visit_id) REFERENCES home_visits(id)
);

CREATE TABLE IF NOT EXISTS veterinarian_specializations (
  veterinarian_id INT NOT NULL,
  specialization_id INT NOT NULL,
  PRIMARY KEY (veterinarian_id, specialization_id),
  FOREIGN KEY (veterinarian_id) REFERENCES veterinarians(id),
  FOREIGN KEY (specialization_id) REFERENCES specializations(id)
);

CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON parcial1_db.* TO 'admin'@'%';
FLUSH PRIVILEGES;

-- INSERTS
INSERT INTO animal_types (name) VALUES
('Dog'), ('Cat'), ('Horse');

INSERT INTO veterinaries (name, NIT, address) VALUES
('Happy Pets Clinic', 'NIT123', 'Street 101 #20-30'),
('Animal Health Center', 'NIT456', 'Street 202 #40-50'),
('Pet Care Plus', 'NIT789', 'Street 303 #60-70');

INSERT INTO owners (identification, firstname, lastname, phone_number, address) VALUES
('CC1001', 'Carlos', 'Gomez', '3001111111', 'Main St 123'),
('CC1002', 'Ana', 'Martinez', '3012222222', 'Second St 456'),
('CC1003', 'Luis', 'Perez', '3023333333', 'Third St 789');

INSERT INTO home_visits (temperature, weight, respiratory_rate, heart_rate, mood, date) VALUES
(38.5, 12.3, 25, 90, 'Active and playful', '2025-09-01'),
(39.0, 8.7, 28, 95, 'Calm but alert', '2025-09-05'),
(37.8, 15.0, 22, 85, 'Anxious', '2025-09-10');

INSERT INTO pets (name, eye_color, height, skin_tone, type_id, owner_id) VALUES
('Pedrin', 'Brown', 50.5, 'Black', 1, 1),
('Mishi', 'Green', 30.0, 'White', 2, 1),
('Lucas', 'Black', 20.0, 'Other', 3, 3);

INSERT INTO veterinarians (identification, firstname, lastname, phone_number, professional_card, veterinary_id) VALUES
('VET001', 'Andrea', 'Lopez', '3104444444', 'CARD001', 1),
('VET002', 'Julian', 'Ramirez', '3115555555', 'CARD002', 2),
('VET003', 'Diana', 'Torres', '3126666666', 'CARD003', 3);

INSERT INTO requests (home_visit_date, pet_id, veterinarian_id, visit_id) VALUES
('2025-09-01', 1, 1, 1),
('2025-09-05', 2, 2, 2),
('2025-09-10', 3, 3, 3);

INSERT INTO veterinarian_specializations (veterinarian_id, animal_type_id) VALUES
(1, 1),
(2, 2),
(3, 3);

-- Queries

-- Total de visitas por medico
SELECT v.firstname, v.lastname, COUNT(*) as num_of_visits
FROM home_visits hv 
JOIN requests r ON hv.id = r.visit_id 
JOIN veterinarians v ON v.id = r.veterinarian_id
GROUP BY v.firstname, v.lastname;

-- Total de visitas por mascotas
SELECT p.name, COUNT(*) as num_of_visits
FROM home_visits hv 
JOIN requests r ON hv.id = r.visit_id 
JOIN pets p ON p.id = r.pet_id 
GROUP BY p.name;

-- Si la visita fue un gato , diga la cantidad de visitas para el gato
SELECT at.name, COUNT(*) as num_of_visits
FROM home_visits hv 
JOIN requests r ON hv.id = r.visit_id 
JOIN pets p ON p.id = r.pet_id
JOIN animal_types at ON at.id = p.type_id
GROUP BY at.name having at.name = 'Cat';

-- Si la visita fue un perro , diga la cantidad de visitas para el perro
SELECT at.name, COUNT(*) as num_of_visits
FROM home_visits hv 
JOIN requests r ON hv.id = r.visit_id 
JOIN pets p ON p.id = r.pet_id
JOIN animal_types at ON at.id = p.type_id
GROUP BY at.name having at.name = 'Dog';

-- Si la visita fue un gato , diga la cantidad de visitas para el callao
SELECT at.name, COUNT(*) as num_of_visits
FROM home_visits hv 
JOIN requests r ON hv.id = r.visit_id 
JOIN pets p ON p.id = r.pet_id
JOIN animal_types at ON at.id = p.type_id
GROUP BY at.name having at.name = 'Horse';

-- Promedio de visitas
SELECT AVG(hv.id) as avg_of_visits
FROM home_visits hv;

-- Total de visitas
SELECT COUNT(*) as total_of_visits
FROM home_visits hv;

-- Total de visitas por medico , ordenado por nombre desc del medico
SELECT v.firstname, v.lastname, COUNT(*) as num_of_visits
FROM home_visits hv 
JOIN requests r ON hv.id = r.visit_id 
JOIN veterinarians v ON v.id = r.veterinarian_id
GROUP BY v.firstname, v.lastname
ORDER BY v.firstname desc;
