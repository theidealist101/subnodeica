sub_bases.register_piece("sub_bases:i_compartment", {
    size = vector.new(5, 5, 11),
    schems = {
        fixed = {
            name = "i_compartment.mts",
            pos = vector.zero()
        }
    },
    recipe = {"sub_core:titanium 2"}
})