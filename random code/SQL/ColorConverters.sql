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

*/
CREATE or Alter FUNCTION dbo.RGBToHSL (@r int, @g int, @b int)
RETURNS @result TABLE (H float, S float, L float)
AS
BEGIN
    declare @r2 float = @r / 255.0;
    declare @g2 float = @g / 255.0;
    declare @b2 float = @b / 255.0;

    declare @min float = (select min(v) from (values (@r2), (@g2), (@b2)) as value(v));
    declare @max float = (select max(v) from (values (@r2), (@g2), (@b2)) as value(v));
    declare @delta float = @max - @min;

    declare @h float = 0;
    declare @s float = 0;
    declare @l float = (@max + @min) / 2;

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
    values (@h, @s * 100, @l * 100);

    return;
END;
go