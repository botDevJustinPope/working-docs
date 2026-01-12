DECLARE @color_palette table (
    [name] varchar(250),
    [hex] varchar(8),
    [r] DECIMAL(8,5),
    [g] DECIMAL(8,5),
    [b] DECIMAL(8,5),
    [h] DECIMAL(8,5),
    [s] DECIMAL(8,5),
    [l] DECIMAL(8,5)
)

insert into @color_palette
select 
    pc.[name],
    pc.[hex],
    rgbConverter.r,
    rgbConverter.g,
    rgbConverter.b,
    hslConverter.h,
    hslConverter.s,
    hslConverter.l
from (
    values 
        ('palette-primary-light-3',     '#5f677b'),
        ('palette-primary-light-2',     '#485268'),
        ('palette-primary-light-1',     '#313c55'),
        ('palette-primary',             '#1b2743'),
        ('palette-primary-dark-1',      '#18233c'),
        ('palette-primary-dark-2',      '#151f35'),
        ('palette-primary-dark-3',      '#121b2e'),
        ('palette-secondary-light-3',   '#58af8c'),
        ('palette-secondary-light-2',   '#40a47c'),
        ('palette-secondary-light-1',   '#28996c'),
        ('palette-secondary',           '#118e5c'),
        ('palette-secondary-dark-1', '#0f7f52'),
        ('palette-secondary-dark-2', '#0d7149'),
        ('palette-secondary-dark-3', '#0b6340'),
        ('palette-tertiary-light-3', '#595f6c'),
        ('palette-tertiary-light-2', '#414857'),
        ('palette-tertiary-light-1', '#293142'),
        ('palette-tertiary', '#121b2e'),
        ('palette-tertiary-dark-1', '#101829'),
        ('palette-tertiary-dark-2', '#0e1524'),
        ('palette-tertiary-dark-3', '#0c1220'),
        ('palette-neutral-light-3', '#f7f7f7'),
        ('palette-neutral-light-2', '#ebebeb'),
        ('palette-neutral-light-1', '#dfdfdf'),
        ('palette-neutral', '#d8d8d8'),
        ('palette-neutral-dark-1', '#acacac'),
        ('palette-neutral-dark-2', '#6c6c6c'),
        ('palette-neutral-dark-3', '#2b2b2b')
) as pc ( [name], [hex] )
    CROSS apply master.dbo.HexToRGB(pc.hex) as rgbConverter
    CROSS apply master.dbo.RGBToHSL(rgbConverter.r, rgbConverter.g, rgbConverter.b) as hslConverter

select * from @color_palette

declare @color_palette_steps_diffs table (
    [start_name] varchar(250),
    [next_name] varchar(250),
    [start_hex] varchar(8),
    [next_hex] varchar(8),
    [delta_r] DECIMAL(8,5),
    [delta_g] DECIMAL(8,5),
    [delta_b] DECIMAL(8,5),
    [delta_h] DECIMAL(8,5),
    [delta_s] DECIMAL(8,5),
    [delta_l] DECIMAL(8,5)
)

Select 
    diffs.start_name,
    diffs.next_name,
    diffs.start_hex,
    diffs.next_hex,
    diffs.delta_r,
    diffs.delta_g,
    diffs.delta_b,
    diffs.delta_h,
    diffs.delta_s,
    diffs.delta_l
from (
    values ('palette-primary', 'palette-primary-light-1'),
           ('palette-primary-light-1', 'palette-primary-light-2'),
           ('palette-primary-light-2', 'palette-primary-light-3'),
           ('palette-primary', 'palette-primary-dark-1'),
           ('palette-primary-dark-1', 'palette-primary-dark-2'),
           ('palette-primary-dark-2', 'palette-primary-dark-3'),
           ('palette-secondary', 'palette-secondary-light-1'),
           ('palette-secondary-light-1', 'palette-secondary-light-2'),
           ('palette-secondary-light-2', 'palette-secondary-light-3'),
           ('palette-secondary', 'palette-secondary-dark-1'),
           ('palette-secondary-dark-1', 'palette-secondary-dark-2'),
           ('palette-secondary-dark-2', 'palette-secondary-dark-3'),
           ('palette-tertiary', 'palette-tertiary-light-1'),
           ('palette-tertiary-light-1', 'palette-tertiary-light-2'),
           ('palette-tertiary-light-2', 'palette-tertiary-light-3'),
           ('palette-tertiary', 'palette-tertiary-dark-1'),
           ('palette-tertiary-dark-1', 'palette-tertiary-dark-2'),
           ('palette-tertiary-dark-2', 'palette-tertiary-dark-3')
) comps ([start_name], [next_name])
    CROSS apply (
        select 
            start.name as start_name,
            next.name as next_name,
            start.hex as start_hex,
            next.hex as next_hex,
            (next.r - start.r) as delta_r,
            (next.g - start.g) as delta_g,
            (next.b - start.b) as delta_b,
            (next.h - start.h) as delta_h,
            (next.s - start.s) as delta_s,
            (next.l - start.l) as delta_l
        from @color_palette start
        join @color_palette next on next.name = comps.next_name
        where start.name = comps.start_name
    ) diffs