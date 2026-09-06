hl.window_rule({
  match = { class = "^(Alacritty)$" },
  opacity = "0.96 override 0.86 override",
})

hl.window_rule({
  match = { class = "^(spotify)$" },
  opacity = "1 override 0.92 override",
})

hl.window_rule({
  match = { class = "^(elecwhat)$" },
  opacity = "1 override 0.92 override",
})

hl.window_rule({
  match = { title = "^(Open File|Save File|Open Folder|Choose Files)$" },
  float = true,
  center = true,
  size = "70% 75%",
})

hl.layer_rule({
    match = { namespace = "eww" },
    blur = true,
    ignore_alpha = 0.0,
})