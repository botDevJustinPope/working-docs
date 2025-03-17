/*
    Arthor : Justin Pope
    Date: 2025-01-17
    Description: takes a hex color code and returns the RGB values as a table


    select * from dbo.HexToRGB('#FFFFFF')
*/

CREATE or Alter FUNCTION dbo.HexToRGB (@hex NVARCHAR(7))
RETURNS TABLE
AS
RETURN
(
    
SELECT 16 * (CHARINDEX(SUBSTRING(@hex, 2, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@hex, 3, 1), '0123456789abcdef') - 1) AS R
      ,16 * (CHARINDEX(SUBSTRING(@hex, 4, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@hex, 5, 1), '0123456789abcdef') - 1) AS G
      ,16 * (CHARINDEX(SUBSTRING(@hex, 6, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@hex, 7, 1), '0123456789abcdef') - 1) AS B
);
go

/*
    Arthor : Justin Pope
    Date: 2025-01-17
    Description: takes a 3 digit hex color code and returns the RGB values as a table


    select * from dbo.HexToRGB('#000000')
*/

create or alter FUNCTION dbo.HexToRGB3 (@hex NVARCHAR(4))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        CAST(CONVERT(INT, SUBSTRING(@hex, 2, 1) + SUBSTRING(@hex, 2, 1), 16) AS FLOAT) / 255.0 AS R,
        CAST(CONVERT(INT, SUBSTRING(@hex, 3, 1) + SUBSTRING(@hex, 3, 1), 16) AS FLOAT) / 255.0 AS G,
        CAST(CONVERT(INT, SUBSTRING(@hex, 4, 1) + SUBSTRING(@hex, 4, 1), 16) AS FLOAT) / 255.0 AS B
);
go

/*
    Arthor : Justin Pope
    Date: 2025-01-17
    Description: takes rgb values and returns the pieces as a table


    select * from dbo.RGBPieces('rgba(0,0,0,0)')
*/
create or alter function dbo.RGBPieces (@rgb NVARCHAR(MAX))
returns table
AS
RETURN
(
    SELECT 
        cast(substring(@rgb, charindex('(',@rgb)+1, charindex(',', @rgb) - (charindex('(',@rgb)+1)) as int) as R,
        cast(substring(@rgb, charindex(',',@rgb)+1, charindex(',', @rgb, charindex(',',@rgb)+1) - charindex(',',@rgb) - 1) as int) as G,
        cast(substring(@rgb, charindex(',',@rgb, charindex(',',@rgb)+1)+1, charindex(')', @rgb) - charindex(',',@rgb, charindex(',',@rgb)+1) - 1) as int) as B
    where @rgb like '%rgb(%,%,%'
    UNION ALL
    SELECT
        cast(substring(@rgb, charindex('(',@rgb)+1, charindex(',', @rgb) - (charindex('(',@rgb)+1)) as int) as R,
        cast(substring(@rgb, charindex(',',@rgb)+1, charindex(',', @rgb, charindex(',',@rgb)+1) - charindex(',',@rgb) - 1) as int) as G,
        cast(substring(@rgb, charindex(',',@rgb, charindex(',',@rgb)+1)+1, charindex(',', @rgb, charindex(',',@rgb, charindex(',',@rgb)+1)+1) - charindex(',',@rgb, charindex(',',@rgb)+1) - 1) as int) as B
    where @rgb like '%rgba(%,%,%,%'
);
go

/*
    Arthor : Justin Pope
    Date: 2025-01-17
    Description: takes a RGB values and returns the hsl values as a table

    select * from dbo.RGBToHSL(0, 0, 0)
    select * from dbo.RGBToHSL(255, 255, 255)
    select * from dbo.RGBToHSL(255, 0, 0)
    select * from dbo.RGBToHSL(0, 255, 0)
    select * from dbo.RGBToHSL(0, 0, 255)
    select * from dbo.RGBToHSL(255, 255, 0)
    select * from dbo.RGBToHSL(0, 255, 255)
    select * from dbo.RGBToHSL(255, 0, 255)
    select * from dbo.RGBToHSL(128, 128, 128)
    select * from dbo.RGBToHSL(128, 0, 0)
    select * from dbo.RGBToHSL(0, 128, 0)
    select * from dbo.RGBToHSL(0, 0, 128)

*/
CREATE or Alter FUNCTION dbo.RGBToHSL (@r int, @g int, @b int)
RETURNS @result TABLE (H int, S decimal(6,5), L decimal(6,5))
AS
BEGIN
    declare @r2 decimal(18,9) = @r / 255.0;
    declare @g2 decimal(18,9) = @g / 255.0;
    declare @b2 decimal(18,9) = @b / 255.0;

    declare @min decimal(18,9) = (select min(v) from (values (@r2), (@g2), (@b2)) as value(v));
    declare @max decimal(18,9) = (select max(v) from (values (@r2), (@g2), (@b2)) as value(v));
    declare @delta decimal(18,9) = @max - @min;

    declare @h int = 0;
    declare @s decimal(6,5) = 0;
    declare @l decimal(6,5) = (@max + @min) / 2;

    if @delta = 0
    begin
        set @h = 0;
        set @s = 0;
    end
    else
    begin
        if @l < 0.5
            set @s = @delta / (@max + @min);
        else
            set @s = @delta / (2 - @max - @min);

        if @r2 = @max
            set @h = (@g2 - @b2) / @delta;
        else if @g2 = @max
            set @h = 2 + (@b2 - @r2) / @delta;
        else
            set @h = 4 + (@r2 - @g2) / @delta;

        set @h = @h * 60;
        if @h < 0
            set @h = @h + 360;
    end

    insert into @result (H, S, L)
    values (@h, @s, @l);

    return;
END;
go

/*
    Arthor : Justin Pope
    Date: 2025-03-10
    Description: takes a hsl values and returns the rgb values as a table

    select * from dbo.HSLToRGB(0, 0, 0)
    select * from dbo.HSLToRGB(0, 1.00, .50)
    select * from dbo.HSLToRGB(120, 1.00, .50)
    select * from dbo.HSLToRGB(240, 1.00, .50)
    select * from dbo.HSLToRGB(0, 1.00, 1.00)
    select * from dbo.HSLToRGB(0, 1.00, 0)
    select * from dbo.HSLToRGB(0, 0, 1.00)

*/
CREATE or ALTER FUNCTION dbo.HSLToRGB (@h float, @s float, @l float)
RETURNS @result TABLE (R int, G int, B int)
AS
BEGIN
    DECLARE @r float;
    DECLARE @g float;
    DECLARE @b float;

    -- Ensure valid ranges for HSL values
    IF @s < 0 OR @s > 1 SET @s = CASE WHEN @s < 0 THEN 0 ELSE 1 END;
    IF @l < 0 OR @l > 1 SET @l = CASE WHEN @l < 0 THEN 0 ELSE 1 END;
    IF @h < 0 SET @h = @h + 360;  -- Handle negative hues
    IF @h > 360 SET @h = @h - 360; -- Normalize hue to be within 0 to 360

    IF @s = 0
    BEGIN
        SET @r = @l;
        SET @g = @l;
        SET @b = @l;
    END
    ELSE
    BEGIN
        DECLARE @q float;
        DECLARE @p float;

        IF @l < 0.5
            SET @q = @l * (1 + @s);
        ELSE
            SET @q = @l + @s - (@l * @s);

        SET @p = 2 * @l - @q;

        DECLARE @hk float = @h / 360.0;
        DECLARE @tr float = @hk + 1.0 / 3.0;
        DECLARE @tg float = @hk;
        DECLARE @tb float = @hk - 1.0 / 3.0;

        -- Ensure all values are wrapped between 0 and 1 for HSL
        IF @tr < 0 SET @tr = @tr + 1;
        IF @tr > 1 SET @tr = @tr - 1;
        IF @tg < 0 SET @tg = @tg + 1;
        IF @tg > 1 SET @tg = @tg - 1;
        IF @tb < 0 SET @tb = @tb + 1;
        IF @tb > 1 SET @tb = @tb - 1;

        SET @r = CASE 
                    WHEN @tr < 1.0 / 6.0 THEN @p + (@q - @p) * 6 * @tr
                    WHEN @tr < 0.5 THEN @q
                    WHEN @tr < 2.0 / 3.0 THEN @p + (@q - @p) * (2.0 / 3.0 - @tr) * 6
                    ELSE @p
                 END;

        SET @g = CASE 
                    WHEN @tg < 1.0 / 6.0 THEN @p + (@q - @p) * 6 * @tg
                    WHEN @tg < 0.5 THEN @q
                    WHEN @tg < 2.0 / 3.0 THEN @p + (@q - @p) * (2.0 / 3.0 - @tg) * 6
                    ELSE @p
                 END;

        SET @b = CASE 
                    WHEN @tb < 1.0 / 6.0 THEN @p + (@q - @p) * 6 * @tb
                    WHEN @tb < 0.5 THEN @q
                    WHEN @tb < 2.0 / 3.0 THEN @p + (@q - @p) * (2.0 / 3.0 - @tb) * 6
                    ELSE @p
                 END;
    END

    -- Insert the calculated RGB values into the result table, ensuring no overflow
    INSERT INTO @result (R, G, B)
    VALUES (CAST(@r * 255 AS INT), CAST(@g * 255 AS INT), CAST(@b * 255 AS INT));

    RETURN;
END;
GO


/*
    Arthor : Justin Pope
    Date: 2025-03-10
    Description: takes a rgb values and returns the hex code as a varchar

    select dbo.RGBToHex(0, 0, 0)
    select dbo.RGBToHex(255, 255, 255)
    select dbo.RGBToHex(255, 0, 0)
    select dbo.RGBToHex(0, 255, 0)
    select dbo.RGBToHex(0, 0, 255)
    select dbo.RGBToHex(255, 255, 0)
    select dbo.RGBToHex(0, 255, 255)
    select dbo.RGBToHex(255, 0, 255)
    select dbo.RGBToHex(128, 128, 128)
    select dbo.RGBToHex(128, 0, 0)
    select dbo.RGBToHex(0, 128, 0)
    select dbo.RGBToHex(0, 0, 128)


*/
CREATE or Alter FUNCTION dbo.RGBToHex (@r int, @g int, @b int)
RETURNS NVARCHAR(7)
AS
BEGIN
    declare @hex NVARCHAR(7) = '#';

    SET @hex = CONCAT('#', 
                      RIGHT('00' + FORMAT(@r, 'X2'), 2), 
                      RIGHT('00' + FORMAT(@g, 'X2'), 2), 
                      RIGHT('00' + FORMAT(@b, 'X2'), 2));
    return @hex;
END;