local colors = {
  black        = '#111111',
  white        = '#ebebeb',
  red          = '#fa8072',
  green        = '#afe1af',
  blue         = '#4d9bc1',
  yellow       = '#fe8019',
  purple       = '#cf9fff',
  gray         = '#aaaaaa',
  darkgray     = '#333333',
  lightgray    = '#504945',
  lightgray2   = '#686868',
}
return {
  normal = {
    a = {bg = colors.blue, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.darkgray, fg = colors.gray},
    z = {bg = colors.lightgray2, fg = colors.white},
  },
  insert = {
    a = {bg = colors.green, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.darkgray, fg = colors.gray},
    z = {bg = colors.lightgray2, fg = colors.white},
  },
  visual = {
    a = {bg = colors.purple, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.darkgray, fg = colors.gray},
    z = {bg = colors.lightgray2, fg = colors.white},
  },
  replace = {
    a = {bg = colors.red, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.darkgray, fg = colors.gray},
    z = {bg = colors.lightgray2, fg = colors.white},
  },
  command = {
    a = {bg = colors.gray, fg = colors.black, gui = 'bold'},
    b = {bg = colors.lightgray, fg = colors.white},
    c = {bg = colors.darkgray, fg = colors.gray},
    z = {bg = colors.lightgray2, fg = colors.white},
  },
  inactive = {
    a = {bg = colors.darkgray, fg = colors.gray, gui = 'bold'},
    b = {bg = colors.darkgray, fg = colors.gray},
    c = {bg = colors.darkgray, fg = colors.gray},
    z = {bg = colors.lightgray2, fg = colors.white},
  }
}
