declare @l_step int = 10;

declare @palette_colors table (
    [name] nvarchar(100) not null,
    [hex] nvarchar(7) not null,
    [r] int not null,
    [g] int not null,
    [b] int not null,
    [h] int not null,
    [s] decimal(10,8) not null,
    [l] decimal(10,8) not null
)

insert into @palette_colors
select 
    pc.name,
    pc.hex,
    0 as [r],
    0 as [g],
    0 as [b],
    0 as [h],
    0.0000 as [s],
    0.0000 as [l]
from (
    values 
        ('palette-primary-light-3',     ''),
        ('palette-primary-light-2',     ''),
        ('palette-primary-light-1',     ''),
        ('palette-primary',             '#1b2743'),
        ('palette-primary-dark-1',      ''),
        ('palette-primary-dark-2',      ''),
        ('palette-primary-dark-3',      ''),
        ('palette-secondary-light-3',   ''),
        ('palette-secondary-light-2',   ''),
        ('palette-secondary-light-1',   ''),
        ('palette-secondary',           '#118e5c'),
        ('palette-secondary-dark-1', ''),
        ('palette-secondary-dark-2', ''),
        ('palette-secondary-dark-3', ''),
        ('palette-tertiary-light-3', ''),
        ('palette-tertiary-light-2', ''),
        ('palette-tertiary-light-1', ''),
        ('palette-tertiary', '#121b2e'),
        ('palette-tertiary-dark-1', ''),
        ('palette-tertiary-dark-2', ''),
        ('palette-tertiary-dark-3', ''),
        ('palette-neutral-light-3', ''),
        ('palette-neutral-light-2', ''),
        ('palette-neutral-light-1', ''),
        ('palette-neutral', '#d8d8d8'),
        ('palette-neutral-dark-1', ''),
        ('palette-neutral-dark-2', ''),
        ('palette-neutral-dark-3', '')
) as pc ( [name], [hex] )

update pc
    set r = rgb.r,
        g = rgb.g,
        b = rgb.b,
        h = hsl.H,
        s = hsl.S,
        l = hsl.L
from @palette_colors pc
    cross apply master.dbo.hextorgb(pc.hex) as rgb
    cross apply master.dbo.rgbtohsl(rgb.r, rgb.g, rgb.b) as hsl
where pc.hex <> ''

select 
    tc.name as [blank_value],
    hsl.*,
    rgb.*,
    master.dbo.RGBToHex(rgb.r, rgb.g, rgb.b) as hex
from @palette_colors tc
    cross apply (
        select 
            left(tc.name, CHARINDEX('-', tc.name, CHARINDEX('-', tc.name) + 1) - 1) as [palette_color],
            substring(tc.name, CHARINDEX('-', tc.name, CHARINDEX('-', tc.name) + 1) + 1, CHARINDEX('-', tc.name, CHARINDEX('-', tc.name, CHARINDEX('-', tc.name) + 1) + 1) - CHARINDEX('-', tc.name, CHARINDEX('-', tc.name) + 1) - 1) as [direction],
            cast(right(tc.name, 1) as int) as [step]
    ) as name_parts
    inner join @palette_colors pc on pc.[name] = name_parts.palette_color
    cross apply (
        select
           (name_parts.step * @l_step) + pc.l as [l]
        where name_parts.direction = 'light'
            and pc.l + (3 * @l_step) < 100
        union 
        select 
            pc.l - (name_parts.step * @l_step) as [l]
        where name_parts.direction = 'dark'
            and pc.l - (3 * @l_step) > 0
        union 
        select 
            pc.l + (name_parts.step * step_calc.step) as [l]
        from ( select (100 - pc.l) / 3 as [step] ) as step_calc
        where name_parts.direction = 'light'
            and pc.l + (3 * @l_step) >= 100
        union
        select 
            pc.l - (name_parts.step * step_calc.step) as [l]
        from ( select pc.l / 3 as [step] ) as step_calc
        where name_parts.direction = 'dark'
            and pc.l - (3 * @l_step) <= 0
    ) as [delta]
    cross apply (select pc.h, pc.s, delta.l) as hsl
    cross apply master.[dbo].[HSLToRGB](hsl.h, hsl.s, hsl.l) as rgb
where tc.hex = '';