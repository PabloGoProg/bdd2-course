-- Queries

-- Listado de empleados que muestre Nombre empleado, Calle y Población, provincia ordenados por DNI del empleado.
SELECT a.name, a.address, b.city_name, b.province_name
FROM
(
SELECT e.DNI, e.name, a.address, a.zip_code
FROM dbo.employees e JOIN dbo.addresses a
ON e.address_id = a.DNI
) as a
JOIN
(
SELECT c.zip, c.name as city_name, p.name as province_name
FROM
(
SELECT *
FROM zip_codes zc JOIN cities c
ON zc.city_id = c.id
) as c
JOIN
provinces p
ON c.province_id = p.id
) as b
ON a.zip_code = b.zip
ORDER BY a.DNI asc;

-- Los empleados que tengan teléfono como los que no en una misma consulta.
SELECT
    e.name as Employee_NAME,
    pn.number as Employee_NUMBER
FROM dbo.employees e
LEFT JOIN dbo.employee_phone_numbers epn
	ON e.DNI = epn.employee_dni
LEFT JOIN dbo.phone_numbers pn
	ON epn.phone_number_dni = pn.DNI
ORDER BY e.DNI asc;

-- Listado del número total de empleados, con el total de teléfonos asociados, ordenados por el que tenga mayor cantidad de teléfonos.
SELECT
	COUNT(*) as num_of_employees,
	npu.num_of_phones
FROM
(
SELECT
    e.name as Employee_NAME,
    COUNT(epn.phone_number_dni) as num_of_phones
FROM dbo.employees e
LEFT JOIN dbo.employee_phone_numbers epn
	ON e.DNI = epn.employee_dni
LEFT JOIN dbo.phone_numbers pn
	ON epn.phone_number_dni = pn.DNI
GROUP BY e.name
) as npu
GROUP BY npu.num_of_phones
ORDER BY num_of_phones desc;

-- Lista el sueldo máximo, el mínimo, el promedio total de sueldos, si el promedio es mayor a $1.500.000 entonces mostrar una nueva columna donde diga que el promedio es bajo, si no debe decir la columna el promedio de alto.
SELECT
	MIN(e.salary) as min_salary,
	MAX(e.salary) as max_salary,
	CEILING(AVG(e.salary)) as avg_salary,
	CASE
        WHEN CEILING(AVG(e.salary)) > 1500000.00 THEN 'PROMEDIO ALTO'
        ELSE 'PROMEDIO BAJO'
    END AS avg_salary_status
FROM dbo.employees e;

-- Listado de sueldo medio y número de empleados por provincia ordenado por provincia.
SELECT
	p.id,
	p.name,
	COUNT(*) as num_of_employees,
	CEILING(AVG(e.salary)) as avg_salary
FROM dbo.provinces p JOIN dbo.zip_codes zc ON p.id = zc.province_id
JOIN dbo.addresses a ON a.zip_code = zc.zip
JOIN dbo.employees e ON e.address_id = a.DNI
GROUP BY p.name, p.id
ORDER BY p.id asc;

-- Listar el total de sueldos pagados de los empleados, sacar una tabla de frecuencias para saber el % de sueldo de c/u de los empleados respecto al total.
SELECT
	e.name,
	e.salary,
	CAST(e.salary * 100 / SUM(e.salary) OVER() as DECIMAL(5,2)) as percentage_over_total
FROM dbo.employees e
ORDER BY percentage_over_total desc;

-- Listar los teléfonos de los empleados, mostrando el nombre del empleado y el teléfono sin el indicativo (601,602, etc.)
SELECT
	e.name,
	SUBSTRING(pn.number, CHARINDEX('-', pn.number) + 1, LEN(pn.number)) as phone_without_indicative
FROM employee_phone_numbers epn
JOIN employees e ON epn.employee_dni = e.DNI
JOIN phone_numbers pn ON epn.phone_number_dni = pn.DNI;

-- Haga un procedimiento almacenado que maneje el CRUD de las tablas Codigo postal y Domicilios.
CREATE OR ALTER PROCEDURE dbo.sp_CRUD_ZipCodes_Addresses
	@TableName NVARCHAR(20),
	@Operation NVARCHAR(20),
	@Id INT = NULL,
	@CityId INT = NULL,
	@ProvinceId INT = NULL,
	@Address NVARCHAR(50) = NULL,
	@ZipCode INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF @TableName = 'zip_codes'
	BEGIN
		IF @Operation = 'CREATE'
		BEGIN
			INSERT INTO dbo.zip_codes (city_id, province_id)
			VALUES (@CityId, @ProvinceId);
		END

		ELSE IF @Operation = 'GET'
		BEGIN
			IF @Id is NULL
				SELECT * from dbo.zip_codes
			ELSE
				SELECT * FROM dbo.zip_codes WHERE zip = @Id;
		END

		ELSE IF @Operation = 'UPDATE'
		BEGIN
			UPDATE dbo.zip_codes
			SET city_id = ISNULL(@CityId, city_id),
				province_id = ISNULL(@ProvinceId, province_id)
			WHERE zip = @Id;
		END

		ELSE IF @Operation = 'DELETE'
        BEGIN
            DELETE FROM dbo.zip_codes WHERE zip = @Id;
        END
	END

	ELSE IF @TableName = 'addresses'
    BEGIN
        IF @Operation = 'CREATE'
        BEGIN
            INSERT INTO dbo.addresses (address, zip_code)
            VALUES (@Address, @ZipCode);
        END

        ELSE IF @Operation = 'GET'
        BEGIN
            IF @Id IS NULL
                SELECT * FROM dbo.addresses;
            ELSE
                SELECT * FROM dbo.addresses WHERE DNI = @Id;
        END

        ELSE IF @Operation = 'UPDATE'
        BEGIN
            UPDATE dbo.addresses
            SET address = ISNULL(@Address, address),
                zip_code = ISNULL(@ZipCode, zip_code)
            WHERE DNI = @Id;
        END

        ELSE IF @Operation = 'DELETE'
        BEGIN
            DELETE FROM dbo.addresses WHERE DNI = @Id;
        END
    END
END

-- Prubas
EXEC dbo.sp_CRUD_ZipCodes_Addresses
    @TableName = 'zip_codes',
    @Operation = 'CREATE',
    @CityId = 1,
    @ProvinceId = 2;

EXEC dbo.sp_CRUD_ZipCodes_Addresses
    @TableName = 'addresses',
    @Operation = 'GET';

EXEC dbo.sp_CRUD_ZipCodes_Addresses
    @TableName = 'zip_codes',
    @Operation = 'GET';

EXEC dbo.sp_CRUD_ZipCodes_Addresses
    @TableName = 'addresses',
    @Operation = 'UPDATE',
    @Id = 3,
    @Address = 'Calle 123B';

EXEC dbo.sp_CRUD_ZipCodes_Addresses
    @TableName = 'zip_codes',
    @Operation = 'DELETE',
    @Id = 2;

-- Elabore una vista que permita extraer todos los empleados con sus teléfonos , el código postal y domicilio , que solo sea de la población de Manizales.
CREATE OR ALTER VIEW dbo.vw_Employees_Manizales
AS
SELECT
	e.DNI as employee_dni,
	e.name as employee_name,
	e.salary,
	a.address,
    zc.zip AS ZipCode,
    c.name AS City,
    p.name AS Province,
    pn.number AS PhoneNumber
FROM dbo.employees e
INNER JOIN dbo.addresses a
	ON e.address_id = a.DNI
INNER JOIN dbo.zip_codes zc
	ON a.zip_code = zc.zip
INNER JOIN dbo.cities c
	ON zc.city_id = c.id
INNER JOIN dbo.provinces p
	ON zc.province_id = p.id
LEFT JOIN dbo.employee_phone_numbers epn
    ON e.DNI = epn.employee_dni
LEFT JOIN dbo.phone_numbers pn
    ON epn.phone_number_dni = pn.DNI
WHERE c.name = 'Manizalezs';

SELECT * FROM dbo.vw_Employees_Manizales;
