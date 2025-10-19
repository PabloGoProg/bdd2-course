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
