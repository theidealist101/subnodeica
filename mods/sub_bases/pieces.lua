sub_bases.register_piece("sub_bases:i_compartment", {
    size = vector.new(5, 5, 11),
    schems = {
        fixed = {
            name = "i_compartment.mts"
        }
    },
    sides = {
        {
            type = "compartment_end",
            pos = vector.new(0, 0, 4),
            size = vector.new(5, 5, 3),
            rot = "180"
        },
        {
            type = "compartment_end",
            pos = vector.new(0, 0, -4),
            size = vector.new(5, 5, 3)
        }
    },
    recipe = {"sub_core:titanium 2"}
})

sub_bases.register_side_piece("sub_bases:hatch", {
    size = vector.new(1, 1, 1),
    suffix = "_hatch",
    types = {"compartment_end"},
    recipe = {"sub_core:titanium 2", "sub_core:quartz"}
})