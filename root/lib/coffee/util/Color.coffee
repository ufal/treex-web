###
Util class to handle colors
###


class Color
  constructor: (red, green, blue) ->
    unless green?
      rgb = hex2rgb(red)
      @red = rgb[0]
      @green = rgb[1]
      @blue = rgb[2]
    else
      @red = red
      @green = green
      @blue = blue

  getHTMLStyle: -> "rbg(#{@red}, #{@green}, #{@blue})"
  getHashStyle: -> "##{@hex()}"

  getRed: -> @red
  getGreen: -> @green
  getBlue: -> @blue

  ###
  Returns the ideal Text Color. Useful for font color selection by
  a given background color.
  ###
  getIdealTextColor: ->
    nTreshold = 105
    bgDelta = @red*0.299 + @green*0.587 + @blue*0.114
    return if (255 - bgDelta < nTreshold) then new Color(0, 0, 0) else new Color(255, 255, 255)

  hex2rgb = (hexcolor) ->
    hexcolor = hexcolor.replace('#', '')
    0 : parseInt(hexcolor.substr(0, 2), 16)
    1 : parseInt(hexcolor.substr(2, 4), 16)
    2 : parseInt(hexcolor.substr(4, 6), 16)

  hex: -> int2hex(@red)+int2hex(@green)+int2hex(@blue)

  int2hex = (c) ->
    c = Math.round(Math.min(Math.max(0, c), 255))
    "0123456789ABCDEF".charAt((c-c%16)/16)+"0123456789ABCDEF".charAt(c%16)

  @colorize = (color) ->
    if color instanceof Color
      return color
    else if typeof color is 'string'
      return new Color(color)
    return null
