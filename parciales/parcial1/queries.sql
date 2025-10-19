USE parcial1_db;

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
