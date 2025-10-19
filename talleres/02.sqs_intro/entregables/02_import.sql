INSERT INTO dbo.cities (name)
VALUES
	('Villamaria'),
	('Manizalezs');

INSERT INTO dbo.provinces (name)
VALUES
	('Enea'),
	('La Floresta'),
	('Centro');

INSERT INTO dbo.zip_codes (city_id, province_id)
VALUES
	(2, 1),
	(1, 2),
	(2, 3);

INSERT INTO dbo.addresses (address, zip_code)
VALUES
	('CRA 12A', 1),
	('CRA 32B', 2),
	('CRA 6A', 1),
	('CRA 7A', 1),
	('CRA 31V', 2),
	('CRA 101-P', 3);

INSERT INTO dbo.employees (name, salary, address_id)
VALUES
	('Daniel Lopez', 1000000.00, 1),
	('Alejandro Alvarez', 2500000.00, 2),
	('Diego Hurtado', 3000000.00, 3),
	('Carolina Gomez', 4500000.00, 4),
	('Orlando Franco', 3200000.00, 5),
	('Ivan Trujillo', 1000000.00, 6);

INSERT INTO dbo.phone_numbers (number)
VALUES
	('606-8913625'),
	('606-2535345'),
	('606-3545645'),
	('606-456456'),
	('606-231231');

INSERT INTO dbo.employee_phone_numbers (employee_dni, phone_number_dni)
VALUES
	(1, 1),
	(1, 2),
	(2, 2),
	(3, 5),
	(4, 4);
