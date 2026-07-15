return {
  -- Rosé Pine palette
  black       = 0xff191724,
  white       = 0xffe0def4,
  red         = 0xffeb6f92,
  green = 0xffb48ead,
  blue        = 0xff9ccfd8,
  yellow      = 0xfff6c177,
  orange      = 0xffea9a97,
  magenta     = 0xffc4a7e7,
  grey        = 0xff6e6a86,
  transparent = 0x00000000,
  puce        = 0xff9b6b6f,  -- dusty puce

  bar = {
    bg     = 0x4a191724,  -- Rosé Pine base, translucent
    border = 0x2ac4a7e7,  -- Iris glass highlight
  },

  popup = {
    bg     = 0xd0191724,
    border = 0x50c4a7e7,
  },

  -- Backgrounds
  bg_solid = 0xff232136,  -- Surface
  bg0      = 0xaa232136,
  bg05     = 0x5a232136,
  bg1      = 0x1a232136,
  bg2      = 0x0ac4a7e7,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}