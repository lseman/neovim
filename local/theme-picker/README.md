# Theme picker

Local Neovim plugin managed by `lua/plugins/ui/themes.lua`. It restores the saved
colorscheme at startup and loads the swatch picker only when opened.

- `require("theme_picker").setup()` restores the saved theme, falling back to
  `ayu-mirage`, then `habamax`.
- `open()`, `close()`, and `toggle()` control the picker.
- Enter saves the selection; Escape or leaving the picker cancels the preview.
- `colors/github-dark.lua` supplies `:colorscheme github-dark`.

Theme state retains the existing `stdpath("data")/theme_picker_last.txt` location.
The Lazy spec supplies the Ayu dependency and both theme shortcuts. No separate
download or repository is required.
