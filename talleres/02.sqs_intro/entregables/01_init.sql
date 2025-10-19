Create Table dbo.cities
(
	id int IDENTITY(1,1) NOT NULL Primary Key,
	name nvarchar(50) NOT NULL
)

Create Table dbo.provinces
(x`
	id int IDENTITY(1,1) NOT NULL Primary Key,
	name nvarchar(50) NOT NULL
)

Create Table dbo.zip_codes
(
	zip int IDENTITY(1,1) NOT NULL Primary Key,
	city_id INT NOT NULL,
	province_id INT NOT NULL,
	CONSTRAINT FK_zip_codes_cities
		FOREIGN KEY (city_id)
		REFERENCES dbo.cities(id),
	CONSTRAINT FK_zip_codes_provinces
		FOREIGN KEY (province_id)
		REFERENCES dbo.provinces(id)
)

Create Table dbo.addresses
(
	DNI int IDENTITY(1,1) NOT NULL Primary Key,
	address nvarchar(50) NOT NULL,
	zip_code INT NOT NULL,
	CONSTRAINT FK_addresses_zip_codes
		FOREIGN KEY (zip_code)
		REFERENCES dbo.zip_codes(zip)
)

Create Table dbo.employees
(
	DNI int IDENTITY(1,1) NOT NULL Primary Key,
	name nvarchar(60) NOT NULL UNIQUE,
	salary DECIMAL(19,4) NOT NULL,
	address_id int,
	CONSTRAINT FK_employees_addresses
		FOREIGN KEY (address_id)
		REFERENCES dbo.addresses(DNI)
)

Create Table dbo.phone_numbers
(
	DNI int IDENTITY(1,1) NOT NULL Primary Key,
	number nvarchar(11) NOT NULL UNIQUE
)

Create Table dbo.employee_phone_numbers
(
	employee_dni int NOT NULL,
	phone_number_dni int NOT NULL,
	CONSTRAINT PK_employee_phone_numbers
        PRIMARY KEY (employee_dni, phone_number_dni),
	CONSTRAINT FK_employee_phone_numbers_employees
		FOREIGN KEY (employee_dni)
		REFERENCES dbo.employees(DNI),
	CONSTRAINT FK_employee_phone_numbers_phone_numbers
		FOREIGN KEY (phone_number_dni)
		REFERENCES dbo.phone_numbers(DNI)
)
