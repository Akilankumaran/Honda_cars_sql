--Group Members:
--Akilan Kumaran
--DATABASE Name: MSBA 230


-- Top 5 best-selling cars accordind to VIN number and Model name of the car and Overall_rating
SELECT TOP 5 h1.VIN, h1.Model, COUNT(*) AS total_sold, AVG(h2.Consumer_Rating) AS overall_rating
FROM honda_sell_data AS h1
JOIN honda_rating_data AS h2 ON h1.VIN = h2.VIN
GROUP BY h1.VIN, h1.Model
ORDER BY total_sold DESC;

--This query will provide you the Model of the car with the average consumer rating of the car for the state of California. 
SELECT Model, AVG(Consumer_Review) AS average_rating
FROM honda_sell_data
WHERE state = 'CA'
GROUP BY Model
ORDER BY average_rating DESC

--This query will provide you the Model and Condition of the car, with State as CA.
SELECT Model, Condition, State
FROM honda_sell_data
WHERE Condition = 'New' AND State = 'CA'
GROUP BY Model, Condition, State


--When you execute this stored procedure, it will return the count of Cars from the "honda_sell_data" table.
IF OBJECT_ID('sp_GetCarsCount') IS NOT NULL
DROP PROCEDURE sp_GetCarsCount;
GO
CREATE PROCEDURE sp_GetCarsCount
AS
BEGIN
    SELECT COUNT(*) AS TotalCars
    FROM honda_sell_data;
END;
GO

-- EXEC satatement is used to retrieve the data from the created stored procedure.
EXEC sp_GetCarsCount; 


-- Created a simple scalar-valued user-defined function (UDF) that takes a VIN as a parameter and returns the corresponding model of the car when the input is given.
-- Drop the function if it exists
IF OBJECT_ID('udf_GetModelByVIN') IS NOT NULL
DROP FUNCTION udf_GetModelByVIN;
GO
--Creating a Function
CREATE FUNCTION udf_GetModelByVIN
(
@VIN NVARCHAR(10)
)
RETURNS NVARCHAR(100)
AS
BEGIN
DECLARE @Model NVARCHAR(100)

    SELECT @Model = Model
    FROM honda_sell_data
    WHERE VIN = @VIN

    RETURN @Model
END;
GO
--Execution of the function
DECLARE @VIN NVARCHAR(20) = '1573637';
SELECT dbo.udf_GetModelByVIN(@VIN) AS Model;


--Created a Table-valued function. This function returns all columns for the specified VIN from the honda_sell_data table.
-- Drop the function if it exists
IF OBJECT_ID('udf_GetCarDetailsByVIN') IS NOT NULL
    DROP FUNCTION udf_GetCarDetailsByVIN;
GO

-- Create the table-valued function
CREATE FUNCTION dbo.udf_GetCarDetailsByVIN
(
    @VIN NVARCHAR(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM honda_sell_data
    WHERE VIN = @VIN
);
GO
--Execution of the Function
DECLARE @ExampleVIN NVARCHAR(20) = '7997184';
SELECT *
FROM dbo.udf_GetCarDetailsByVIN(@ExampleVIN);

--Checks if a view named 'TopRatedModelsView' exists, and if it does, drops it.
--Creates a new view named 'TopRatedModelsView' by selecting the Model, the average Consumer Rating, and the ranking of each Honda model based on consumer ratings from two tables (honda_rating_data and honda_sell_data).
--Finally, queries the new view to retrieve the model, average rating, and ranking of the top-rated model.


IF OBJECT_ID('TopRatedModelView') IS NOT NULL
    DROP VIEW TopRatedModelsView;
GO
CREATE VIEW TopRatedModelsView AS
SELECT
    h2.Model,
    AVG(h1.Consumer_Rating) AS avg_rating,
    ROW_NUMBER() OVER (ORDER BY AVG(h1.Consumer_Rating) DESC) AS ranking
FROM
    dbo.honda_rating_data h1
JOIN
    dbo.honda_sell_data h2 ON h2.VIN = h1.VIN
GROUP BY
    h2.Model;

-- Now you can query the view
SELECT Model, avg_rating, ranking
FROM TopRatedModelsView
WHERE ranking = 1;





