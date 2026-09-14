-- NOTE: shared by skkeleton (input) and kensaku (search) so that a search
-- pattern typed in AZIK is interpreted with the same table as the input.
return {
  overrides = {
    l = "disable",
    la = false,
    li = false,
    lu = false,
    le = false,
    lo = false,
    lya = false,
    lyu = false,
    lyo = false,
    [":"] = "henkanPoint",
    -- NOTE: from https://github.com/NI57721/dotfiles
    xxa = { "ぁ" },
    xxi = { "ぃ" },
    xxu = { "ぅ" },
    xxe = { "ぇ" },
    xxo = { "ぉ" },
    xxya = { "ゃ" },
    xxyu = { "ゅ" },
    xxyo = { "ょ" },
    xxwa = { "ゎ" },
    -- NOTE: override azik table
    rr = { "れる" },
    -- NOTE: my extend table
    nn = { "なん" },
  },
}
