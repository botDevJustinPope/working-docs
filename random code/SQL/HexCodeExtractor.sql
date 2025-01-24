/*
    Author: Justin Pope
    Date: 2025-01-17
    Description: Extracts hex values from a string
*/
CREATE FUNCTION dbo.ExtractHexValues (@input NVARCHAR(MAX))
RETURNS @HexValues TABLE (HexValue NVARCHAR(7))
AS
BEGIN
    DECLARE @pos INT = 1
    DECLARE @len INT = LEN(@input)
    DECLARE @hex NVARCHAR(7)

    WHILE @pos <= @len
    BEGIN
        SET @pos = PATINDEX('%#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]%', SUBSTRING(@input, @pos, @len - @pos + 1))
        IF @pos = 0 BREAK

        SET @hex = SUBSTRING(@input, @pos, 7)
        INSERT INTO @HexValues (HexValue) VALUES (@hex)

        SET @pos = @pos + LEN(@hex)
    END

    RETURN
END;
go