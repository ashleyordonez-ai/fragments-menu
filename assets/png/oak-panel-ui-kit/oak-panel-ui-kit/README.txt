Oak Panel UI Kit — double-framed panels and buttons
===================================================

18 warm oak interface sprites: double-framed nine-slice panels, a tooltip, a
header bar, a divider, a chip and twelve tab button states. SVG plus
transparent PNG.

A warm wooden frame for the kind of game that has an inventory grid and a
quest log. Two concentric borders with a gap between them give it a carved
look instead of a flat brown rectangle, and the tab-shaped buttons sit on a
brass baseline so a row of them reads as a set of pages rather than a row of
separate controls. Everything here is a size up from a standard kit, because a
fantasy menu is usually looked at, not glanced at.

Two nine-slice panels — a double-framed window frame with 32 px corners and a
recessed inset frame with 20 px corners — cover almost every box a menu needs:
dialogs, inventory grids, list backgrounds, tooltips and stat panels. Two
concentric borders with a gap between them read as carved rather than drawn,
which is what separates a crafted interface from a rectangle with a stroke.
Both stretch cleanly to any size because the corners never scale and the
centre is a flat fill.

On top of the panels sit twelve tab button sprites: default, hover, pressed
and disabled, each drawn three times — a standard 160×48 bar, a square icon
button and a compact button for toolbars and inline actions. The three sizes
are separate files rather than one scaled sprite because the drawing is
size-dependent: the chamfer computed at 48 px is recomputed at the smaller
ones, not shrunk. The pressed state drops its face two pixels and removes the
top highlight rather than just darkening, which is what makes a button feel
clicked rather than merely recoloured.

Four smaller parts cover what a menu needs between the panels: a tooltip with
a pointer tail, a header bar that sits along the top of a panel, a section
divider with a centre mark, and a label chip for counts and status tags. None
of them are the window panel at another size — a nine-slice already stretches
to any size, so a second file at a different width would be filler rather than
a component.

Everything ships twice. The SVG sources are the files the kit was drawn in —
open them, change the six wood-brown tones or the single polished brass
accent, and re-export. The PNG exports are flat, transparent and pre-scaled at
1x, 2x and 4x for engines that want bitmaps, with no premultiplied alpha and
no baked-in shadow outside the sprite bounds.

HOW TO USE

  - In Unity, import the PNGs, set Texture Type to Sprite (2D and UI), and set
    the border to 32, 32, 32, 32 for the window panel and 16, 16, 16, 16 for
    the buttons; then set Image Type to Sliced on the UI component.
  - In Godot 4, use a NinePatchRect and set the patch margins to the same
    numbers, or drop the SVG straight in and let Godot rasterise it at the
    scale you set in the import options.
  - In Unreal, import as a Texture2D, create a Slate Brush with Draw As set to
    Box, and enter the margin as a fraction of the texture size — 0.25 for the
    128 px panel and 0.1 for the 160 px button.
  - For crisp results at non-integer UI scales, use the 2x or 4x PNG rather
    than upscaling the 1x, or point your engine at the SVG source and let it
    rasterise at the final size.
  - The brass accent is a single value in the SVG — swapping it for silver or
    verdigris re-skins the whole kit for a different faction without touching
    the wood tones.

License: CC-BY-4.0 — see LICENSE.txt
Page: https://www.colorosse.com/assets/2d/ui/oak-panel-ui-kit
More free assets: https://www.colorosse.com
