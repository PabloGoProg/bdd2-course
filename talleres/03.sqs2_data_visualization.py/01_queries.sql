-- a). Ventas totales por anio
SELECT
    YEAR(h.OrderDate) AS Anio,
    SUM(h.TotalDue) AS Ventas_Total
FROM Sales.SalesOrderHeader AS h
WHERE h.Status = 5  -- Excluir las ventas canceladas
GROUP BY YEAR(h.OrderDate)
ORDER BY Anio;

-- b). Ventas separadas por canal: Internet vs. Tienda
SELECT
	YEAR(h.OrderDate) AS Anio,
	CASE WHEN h.OnlineOrderFlag = 1 THEN 'Internet' ELSE 'Tienda' END AS Canal,
	SUM(h.TotalDue)   AS Ventas_Total
FROM Sales.SalesOrderHeader as h
WHERE h.Status = 5
GROUP BY
	YEAR(h.OrderDate),
	CASE WHEN h.OnlineOrderFlag = 1 THEN 'Internet' ELSE 'Tienda' END
ORDER BY Anio, Canal;

-- c). Ventas por producto - Sin canal
SELECT
	p.ProductID,
	p.ProductNumber,
	p.Name AS Producto,
	SUM(d.LineTotal) AS Ventas
FROM Sales.SalesOrderDetail AS d
JOIN Sales.SalesOrderHeader AS h ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = d.ProductID
WHERE h.Status = 5
GROUP BY p.ProductID, p.ProductNumber, p.Name
ORDER BY Ventas DESC, p.ProductID;

-- d) Total de ventas por cliente
SELECT
	c.CustomerID,
	COALESCE(s.Name, 
		LTRIM(RTRIM(CONCAT(p.FirstName, ' ', ISNULL(p.MiddleName + ' ', ''), p.LastName))), 
	c.AccountNumber) as Cliente,
	SUM(h.TotalDue) as Total_Ventas,
	COUNT(DISTINCT h.SalesOrderID) as Numero_Pe
FROM Sales.SalesOrderHeader as h
JOIN Sales.Customer as c ON c.CustomerID = h.CustomerID
LEFT JOIN Sales.Store AS s ON s.BusinessEntityID = c.StoreID
LEFT JOIN Person.Person AS p ON p.BusinessEntityID = c.PersonID
WHERE h.Status = 5
GROUP BY 
	c.CustomerID, s.Name, p.FirstName, p. MiddleName, p.LastName, c.AccountNumber
ORDER BY Total_Ventas desc;

-- e) Primera compra de cada cliente
SELECT
    c.CustomerID,
    COALESCE(s.Name,
    	LTRIM(RTRIM(CONCAT(p.FirstName, ' ', ISNULL(p.MiddleName + ' ', ''), p.LastName))),
    c.AccountNumber) AS Cliente,
    MIN(h.OrderDate) AS FechaPrimeraCompra
FROM Sales.SalesOrderHeader AS h
JOIN Sales.Customer AS c ON c.CustomerID          = h.CustomerID
LEFT JOIN Sales.Store AS s ON s.BusinessEntityID    = c.StoreID
LEFT JOIN Person.Person AS p ON p.BusinessEntityID    = c.PersonID
WHERE h.Status = 5
GROUP BY
    c.CustomerID, s.Name, p.FirstName, p.MiddleName, p.LastName, c.AccountNumber
ORDER BY FechaPrimeraCompra;

-- f) Clientes por año de primera compra (nuevos por año)
WITH PrimeraCompra AS (
    SELECT
        h.CustomerID,
        MIN(h.OrderDate) AS FechaPrimeraCompra
    FROM Sales.SalesOrderHeader AS h
    WHERE h.Status = 5
    GROUP BY h.CustomerID
)
SELECT
    YEAR(FechaPrimeraCompra) AS Anio,
    COUNT(*) AS NuevosClientes
FROM PrimeraCompra
GROUP BY YEAR(FechaPrimeraCompra)
ORDER BY Anio;

-- g) Todos los empleados con sus departamentos actuales:
SELECT
    e.BusinessEntityID AS EmployeeID,
    LTRIM(RTRIM(CONCAT(pp.FirstName, ' ', ISNULL(pp.MiddleName + ' ', ''), pp.LastName))) AS Empleado,
    e.JobTitle,
    d.Name AS Departamento,
    edh.StartDate AS Desde,
    sh.Name AS Turno
FROM HumanResources.Employee AS e
JOIN Person.Person AS pp ON pp.BusinessEntityID = e.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory AS edh ON edh.BusinessEntityID = e.BusinessEntityID
JOIN HumanResources.Department AS d ON d.DepartmentID = edh.DepartmentID
JOIN HumanResources.Shift AS sh ON sh.ShiftID = edh.ShiftID
WHERE edh.EndDate IS NULL
ORDER BY d.Name, Empleado;

-- h) Empleados por departamento y año de inicio
SELECT
    d.Name AS Departamento,
    YEAR(edh.StartDate) AS AnioInicio,
    COUNT(DISTINCT edh.BusinessEntityID) AS EmpleadosQueInician
FROM HumanResources.EmployeeDepartmentHistory AS edh
JOIN HumanResources.Department AS d ON d.DepartmentID = edh.DepartmentID
GROUP BY d.Name, YEAR(edh.StartDate)
ORDER BY d.Name, AnioInicio;

-- Respuesta a las preguntas clave
-- a) ¿Cuál es la evolución de las ventas por producto y por canal (Internet vs Tienda) en los últimos años?
DECLARE @Anos INT = 5; -- Numero de annos en el pasado a analizar

DECLARE @MaxOrderDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader); -- Fecha del ultimo pedido
DECLARE @MinYear INT = YEAR(DATEADD(YEAR, -(@Anos - 1), @MaxOrderDate)); -- ultimo anno de analisis

SELECT
    YEAR(h.OrderDate) AS Anio,
    CASE WHEN h.OnlineOrderFlag = 1 THEN 'Internet' ELSE 'Tienda' END AS Canal,
    p.ProductID,
    p.ProductNumber,
    p.Name AS Producto,
    SUM(d.LineTotal) AS Ventas
FROM Sales.SalesOrderHeader AS h
JOIN Sales.SalesOrderDetail AS d ON d.SalesOrderID = h.SalesOrderID
JOIN Production.Product AS p ON p.ProductID = d.ProductID
WHERE YEAR(h.OrderDate) >= @MinYear
AND h.Status = 5
GROUP BY
    YEAR(h.OrderDate),
    CASE WHEN h.OnlineOrderFlag = 1 THEN 'Internet' ELSE 'Tienda' END,
    p.ProductID, p.ProductNumber, p.Name
ORDER BY Anio, Canal, Ventas DESC, p.ProductID;


-- b) ¿Qué porcentaje de las ventas proviene de clientes nuevos vs clientes recurrentes?
WITH Ordenes AS (
    SELECT
        h.SalesOrderID,
        h.CustomerID,
        h.OrderDate,
        h.TotalDue,
        ROW_NUMBER() OVER (PARTITION BY h.CustomerID ORDER BY h.OrderDate, h.SalesOrderID) AS rn
    FROM Sales.SalesOrderHeader AS h
    WHERE h.Status = 5
),
Clas AS (
    SELECT
        CASE WHEN rn = 1 THEN 'Nuevo' ELSE 'Recurrente' END AS TipoCliente,
        TotalDue
    FROM Ordenes
)
SELECT
    TipoCliente,
    SUM(TotalDue) AS Ventas,
    100.0 * SUM(TotalDue) / SUM(SUM(TotalDue)) OVER () AS Porcentaje
FROM Clas
GROUP BY TipoCliente
ORDER BY TipoCliente;

-- c) ¿Cómo ha evolucionado el número de empleados por departamento en los últimos años?
DECLARE @Anos INT = 5;
DECLARE @MaxEmpDate DATE = (
    SELECT MAX(ISNULL(edh.EndDate, edh.StartDate))
    FROM HumanResources.EmployeeDepartmentHistory AS edh
);
DECLARE @MinYear INT = YEAR(DATEADD(YEAR, -(@Anos - 1), @MaxEmpDate));

;WITH Anios AS (
    SELECT @MinYear AS Anio
    UNION ALL
    SELECT Anio + 1 FROM Anios WHERE Anio + 1 <= YEAR(@MaxEmpDate)
),
Snapshot AS (
    -- Una fila por empleado-departamento vigente al 31-Dic de cada año
    SELECT DISTINCT
        a.Anio,
        d.DepartmentID,
        d.Name AS Departamento,
        edh.BusinessEntityID
    FROM Anios AS a
    JOIN HumanResources.EmployeeDepartmentHistory AS edh
      ON edh.StartDate <= DATEFROMPARTS(a.Anio, 12, 31)
     AND (edh.EndDate IS NULL OR edh.EndDate > DATEFROMPARTS(a.Anio, 12, 31))
    JOIN HumanResources.Department AS d
      ON d.DepartmentID = edh.DepartmentID
)
SELECT
    s.Anio,
    s.Departamento,
    COUNT(DISTINCT s.BusinessEntityID) AS Empleados,
    COUNT(DISTINCT s.BusinessEntityID)
      - LAG(COUNT(DISTINCT s.BusinessEntityID)) OVER (PARTITION BY s.Departamento ORDER BY s.Anio) AS VariacionYoY
FROM Snapshot AS s
GROUP BY s.Anio, s.Departamento
ORDER BY s.Anio, s.Departamento
OPTION (MAXRECURSION 1000);

-- Creacion de Vistas

-- a) Evolución de ventas por producto y canal (Internet vs Tienda)
CREATE OR ALTER VIEW dbo.vw_Sales_per_Channel
AS
	SELECT
	    YEAR(h.OrderDate) AS Anio,
	    CASE WHEN h.OnlineOrderFlag = 1 THEN 'Internet' ELSE 'Tienda' END AS Canal,
	    p.ProductID,
	    p.ProductNumber,
	    p.Name AS Producto,
	    SUM(d.LineTotal) AS Ventas
	FROM Sales.SalesOrderHeader AS h
	JOIN Sales.SalesOrderDetail AS d ON d.SalesOrderID = h.SalesOrderID
	JOIN Production.Product AS p ON p.ProductID = d.ProductID
	WHERE h.Status = 5
	GROUP BY
	    YEAR(h.OrderDate),
	    CASE WHEN h.OnlineOrderFlag = 1 THEN 'Internet' ELSE 'Tienda' END,
	    p.ProductID, p.ProductNumber, p.Name;

SELECT * FROM dbo.vw_Sales_per_Channel;

-- b) ¿Qué porcentaje de las ventas proviene de clientes nuevos vs clientes recurrentes?
CREATE OR ALTER VIEW dbo.vw_sells_percentage
AS
	WITH Ordenes AS (
	    SELECT
	        h.SalesOrderID,
	        h.CustomerID,
	        h.OrderDate,
	        h.TotalDue,
	        ROW_NUMBER() OVER (PARTITION BY h.CustomerID ORDER BY h.OrderDate, h.SalesOrderID) AS rn
	    FROM Sales.SalesOrderHeader AS h
	    WHERE h.Status = 5
	),
	Clas AS (
	    SELECT
	        CASE WHEN rn = 1 THEN 'Nuevo' ELSE 'Recurrente' END AS TipoCliente,
	        TotalDue
	    FROM Ordenes
	)
	SELECT
	    TipoCliente,
	    SUM(TotalDue) AS Ventas,
	    100.0 * SUM(TotalDue) / SUM(SUM(TotalDue)) OVER () AS Porcentaje
	FROM Clas
	GROUP BY TipoCliente;

SELECT * FROM dbo.vw_sells_percentage;

-- c) Evolución del número de empleados por departamento (headcount anual)
CREATE OR ALTER VIEW dbo.vw_employee_nuber_evolution_per_department
AS
	WITH Bounds AS (
	    SELECT
	        MIN(YEAR(StartDate)) AS MinYear,
	        MAX(YEAR(ISNULL(EndDate, StartDate))) AS MaxYear
	    FROM HumanResources.EmployeeDepartmentHistory
	),
	Anios AS (
	    SELECT b.MinYear AS Anio FROM Bounds AS b
	    UNION ALL
	    SELECT a.Anio + 1
	    FROM Anios AS a
	    CROSS JOIN Bounds AS b
	    WHERE a.Anio + 1 <= b.MaxYear
	),
	Snapshot AS (
	    -- empleado-depto vigente al 31-Dic de cada año
	    SELECT DISTINCT
	        a.Anio,
	        d.DepartmentID,
	        d.Name AS Departamento,
	        edh.BusinessEntityID
	    FROM Anios AS a
	    JOIN HumanResources.EmployeeDepartmentHistory AS edh
	      ON edh.StartDate <= DATEFROMPARTS(a.Anio, 12, 31)
	     AND (edh.EndDate IS NULL OR edh.EndDate > DATEFROMPARTS(a.Anio, 12, 31))
	    JOIN HumanResources.Department AS d
	      ON d.DepartmentID = edh.DepartmentID
	),
	Headcount AS (
	    SELECT
	        s.Anio,
	        s.Departamento,
	        COUNT(DISTINCT s.BusinessEntityID) AS Empleados
	    FROM Snapshot AS s
	    GROUP BY s.Anio, s.Departamento
	)
	SELECT
	    h.Anio,
	    h.Departamento,
	    h.Empleados,
	    LAG(h.Empleados) OVER (PARTITION BY h.Departamento ORDER BY h.Anio) AS Empleados_AnioPrevio,
	    h.Empleados - ISNULL(LAG(h.Empleados) OVER (PARTITION BY h.Departamento ORDER BY h.Anio), 0) AS VariacionYoY
	FROM Headcount AS h;

SELECT * FROM dbo.vw_employee_nuber_evolution_per_department;

-- Procedimiento almacenado para el CRUD de la tabla empleados
CREATE OR ALTER PROCEDURE HumanResources.usp_Empleado_CRUD
    @Accion NVARCHAR(10),                   -- 'INSERT', 'SELECT', 'UPDATE', 'DELETE'
    @BusinessEntityID INT = NULL,
    @NationalIDNumber NVARCHAR(15) = NULL,
    @LoginID NVARCHAR(256) = NULL,
    @JobTitle NVARCHAR(50) = NULL,
    @BirthDate DATE = NULL,
    @MaritalStatus NCHAR(1) = NULL,
    @Gender NCHAR(1) = NULL,
    @HireDate DATE = NULL,
    @SalariedFlag BIT = NULL,
    @VacationHours SMALLINT = NULL,
    @SickLeaveHours SMALLINT = NULL,
    @CurrentFlag BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @Accion = 'INSERT'
    BEGIN
        INSERT INTO HumanResources.Employee
            (BusinessEntityID, NationalIDNumber, LoginID, JobTitle,
             BirthDate, MaritalStatus, Gender, HireDate, 
             SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag)
        VALUES
            (@BusinessEntityID, @NationalIDNumber, @LoginID, @JobTitle,
             @BirthDate, @MaritalStatus, @Gender, @HireDate, 
             @SalariedFlag, @VacationHours, @SickLeaveHours, @CurrentFlag);

        PRINT 'Empleado insertado correctamente.';
    END
    
    ELSE IF @Accion = 'SELECT'
    BEGIN
        IF @BusinessEntityID IS NULL
            SELECT * FROM HumanResources.Employee;
        ELSE
            SELECT * FROM HumanResources.Employee WHERE BusinessEntityID = @BusinessEntityID;
    END

    ELSE IF @Accion = 'UPDATE'
    BEGIN
        UPDATE HumanResources.Employee
        SET
            NationalIDNumber = ISNULL(@NationalIDNumber, NationalIDNumber),
            LoginID = ISNULL(@LoginID, LoginID),
            JobTitle = ISNULL(@JobTitle, JobTitle),
            BirthDate = ISNULL(@BirthDate, BirthDate),
            MaritalStatus = ISNULL(@MaritalStatus, MaritalStatus),
            Gender = ISNULL(@Gender, Gender),
            HireDate = ISNULL(@HireDate, HireDate),
            SalariedFlag = ISNULL(@SalariedFlag, SalariedFlag),
            VacationHours = ISNULL(@VacationHours, VacationHours),
            SickLeaveHours = ISNULL(@SickLeaveHours, SickLeaveHours),
            CurrentFlag = ISNULL(@CurrentFlag, CurrentFlag)
        WHERE BusinessEntityID = @BusinessEntityID;

        PRINT 'Empleado actualizado correctamente.';
    END

    ELSE IF @Accion = 'DELETE'
    BEGIN
        DELETE FROM HumanResources.Employee
        WHERE BusinessEntityID = @BusinessEntityID;

        PRINT 'Empleado eliminado correctamente.';
    END

    ELSE
    BEGIN
        PRINT 'Acción no válida. Use INSERT, SELECT, UPDATE o DELETE.';
    END
END;

-- Ejemplos de uso para el CRUD

-- Create

EXEC HumanResources.usp_Empleado_CRUD
    @Accion = 'INSERT',
    @BusinessEntityID = 291,  -- uno nuevo
    @NationalIDNumber = '987654321',
    @LoginID = 'adventure-works\\mario.salgado',
    @JobTitle = 'Sales Representative',
    @BirthDate = '1995-06-12',
    @MaritalStatus = 'S',
    @Gender = 'M',
    @HireDate = '2024-07-01',
    @SalariedFlag = 1,
    @VacationHours = 20,
    @SickLeaveHours = 10;

-- Read

EXEC HumanResources.usp_Empleado_CRUD @Accion = 'SELECT';

EXEC HumanResources.usp_Empleado_CRUD
    @Accion = 'SELECT',
    @BusinessEntityID = 291;

-- Update

EXEC HumanResources.usp_Empleado_CRUD
    @Accion = 'UPDATE',
    @BusinessEntityID = 291,
    @JobTitle = 'Senior Sales Representative',
    @VacationHours = 25;

-- Delete

EXEC HumanResources.usp_Empleado_CRUD
    @Accion = 'DELETE',
    @BusinessEntityID = 291;
