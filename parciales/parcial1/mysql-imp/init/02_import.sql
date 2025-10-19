USE parcial1_db;

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
