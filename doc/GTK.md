# GTK 4 interface

The optional `gtk` package (`0.1.0`, `import gtk`, namespace `Gtk`) provides a
compact GTK-aligned interface: `Application`, `Widget`, `Window`, `Box`, `Label`,
`Button`, `Entry`, `CheckButton`, `ScrolledWindow`, `Notebook`, `MenuBar`,
`ContextMenu`, `Scrollbar`, `Scale`, `ProgressBar`, `SpinButton`, `DropDown`,
`Frame`, `Expander`, `Separator`, `TextView`, `FileDialog`, `Paned`,
`DrawingArea`, `Tree`, `DirectoryScan`, and `SignalConnection`, plus the optional
`sourceview` package. It is not a complete GTK binding or a generic GUI
framework.

## Build and package linkage

Fresh configurations enable `CWHIP_GTK` when GTK 4.10 or newer development files and
`pkg-config` are available, and enable `CWHIP_GTK_SOURCEVIEW` when GtkSourceView 5
is also available. Explicit `ON` options require the corresponding dependencies.
With `BUILD_TESTING=ON`, headless tests default to enabled when Xvfb and
`dbus-daemon` are found; `CWHIP_GTK_TESTS=ON` requires them explicitly.
With `CWHIP_GTK=OFF` and `CWHIP_GTK_SOURCEVIEW=OFF`, the GTK package is absent from staged/installed
standard modules. With it on, `lib/libcwhip_gtk.a` resides inside
`share/cwhip/modules/gtk/0.1.0/`, beside the source and manifest.

Package `[link]` metadata links importing applications with `cwhip_gtk`, `gtk-4`,
`gio-2.0`, `gobject-2.0`, `glib-2.0`, `pango-1.0`, `pangocairo-1.0`, and `cairo`.
The compiler and non-import applications remain unlinked to GTK. Compile-only
objects retain package link sidecars.
Installed consumers use the normal `cwhip-pkg init` / `cwhip-pkg install` lock flow.
GTK runtime libraries and a usable display are external requirements; they
are not bundled. The native platform remains POSIX.

## Application and activation

Construct exactly one `Application(String id)` on the registered Cwhip thread
that will own GTK. The ID must be a valid GApplication ID, such as
`"org.example.Editor"`. `onActivate(void<> action)` returns a connection;
install activation handlers **before** `run()`. Create windows and widgets
during local activation or afterward on the same GUI thread, not before `run()`.
Each `Window` automatically associates with this `GtkApplication`.
GTK initialization installs a log writer that drops the known
`Trying to snapshot GtkGizmo … without a current allocation` warning from
`GtkTextView` updating scroll adjustments during paint (GTK #6057).

`run()` calls the real `g_application_run()`: GTK handles desktop activation,
application registration, and normal single-instance behavior on the session
bus. A second process with the same ID forwards activation to the primary
process; its local activation handlers do not run. Activation can occur more
than once in the primary process, so handlers should present existing windows
when appropriate. No command-line/open-file API is provided yet; the GTK run
call does not consume Cwhip's program arguments.

Closing the last application window normally ends the run. `quit()` requests
exit and requires an active run; it does not pretend that closing was approved.
`run()` is single-use and **terminal**: on return it performs `shutdown()`.
`shutdown()` is GUI-only, terminal and idempotent, and is safe inside a handler
or before running. It cancels pending posts, disconnects every signal, disposes
all widgets (including detached widgets), and releases the native application.
Native application release is kept safe while a run or emission is unwinding.
Outstanding `Config.save` operations are drained before shutdown; their
completion callbacks are suppressed during teardown and failures go to stderr.
Reinitialization and nested runs are rejected.

`Window.close()` sends GTK's close request and requires a realized/presented
window; use `dispose()` to tear down a window that has not been presented.
Calling close before presentation is rejected rather than silently doing nothing.

`String id()` returns a managed copy of the application ID while live.
`int64 post(void<> action)` is the only worker-callable GUI operation;
it queues one invocation on the GUI thread and returns a positive, process-unique
token. `int64 schedule(int64 milliseconds, void<> action)` queues the same kind
of one-shot callback after a delay. The returned token can be passed to `cancel`. `bool cancel(int64 token)` is GUI-only: true means pending work was removed,
false means it was already cancelled/running/completed or was never pending.
Tokens are never reused. Posts before initialization or after shutdown abort
with an explicit diagnostic. Coordinate worker completion before requesting
exit if workers might still submit work. Posts do not independently hold a GUI
application open: keep an application window alive until needed work finishes.

For foundation compatibility, `Application()` is a stateless reference to this
same process-wide lifecycle (useful for `post`, `cancel`, `quit`, and `shutdown`
inside handlers). It creates no second application. Legacy
`Application().initialize()` initializes a real GtkApplication with ID
`org.cwhip.Scheduler` and an explicit hold until `quit`/`shutdown`, so
scheduler-only foundation programs still work. Prefer the ID constructor for
new GUI programs. The old custom context-iteration loop is gone; repeated
`run()` and connecting/posting after a run intentionally no longer work.

## Widgets and properties

`Widget` is a protected construction base, not a raw-handle wrapper users
instantiate directly. Every concrete widget inherits:

```text
void dispose()
bool disposed()
void setVisible(bool value)
void setSensitive(bool value)
void setHExpand(bool value)
void setVExpand(bool value)
void setWidthRequest(int64 width)
void addCssClass(String name)
void removeCssClass(String name)
void setTooltip(String text)
```

The first-release additions are:

| Class | Constructor and operations |
| --- | --- |
| `Widget` | `setVisible(bool)`, `bool visible()`, `setSensitive(bool)`, `setHExpand(bool)`, `setVExpand(bool)`, `setWidthRequest(int64)`, `addCssClass(String)`, `removeCssClass(String)`, `setTooltip(String)`, `setFocusOnClick(bool)`, `setCanFocus(bool)`, `dispose()`, `bool disposed()` |
| `Window` | `Window(String title)`, `setTitle(String)`, `String title()`, `setDefaultSize(int64 width, int64 height)`, `int64 defaultWidth()`, `int64 defaultHeight()`, `setTransientFor(Window parent)`, `setChild(Widget)`, `remove(Widget)`, `present()`, `close()`, `onCloseRequest(bool<>)`, `onFocusChanged(void<bool>)`, `bindShortcut(String trigger, void<>)`, `bool hasShortcut(String trigger)`, `clearShortcuts()`, `setMenubarAccel(bool)`, `bool menubarAccel()` |
| `Paned` | `Paned()` (horizontal), `Paned(int64 orientation)` with `Paned.HORIZONTAL` / `Paned.VERTICAL`, `append(Widget)`, `setPosition(int64)`, `int64 position()` |
| `DrawingArea` | `DrawingArea()`, `queueDraw()`, `setContentSize(int64 width, int64 height)`, `onDraw(void<int64, int64>)`, `onClick(void<int64, fp64, fp64>)`, `onDrag(void<int64, fp64, fp64, fp64, fp64>)`, `onScroll(void<fp64, fp64, fp64, fp64>)`, paint helpers `setColor` / `setLineWidth` / `fillRect` / `strokeRect` / `fillCircle` / `strokeCircle` / `strokeLine` (valid only inside `onDraw`) |
| `TransientWindow` | `TransientWindow(String title)`, `setTitle(String)`, `String title()`, `setDefaultSize(int64 width, int64 height)`, `int64 defaultWidth()`, `int64 defaultHeight()`, `setTransientFor(Window parent)`, `setChild(Widget)`, `remove(Widget)`, `present()`, `close()`, `onCloseRequest(bool<>)` |
| `Box` | `Box(int64 orientation, int64 spacing)`, `setLayout(int64 orientation, int64 spacing)`, `append(Widget)`, `remove(Widget)` |
| `Grid` | `Grid(int64 spacing)`, `attach(Widget, int64 column, int64 row, int64 width, int64 height)` |
| `ContextMenu` | `ContextMenu(Widget owner)`, `addItem` / `addCheckItem` (root or submenu), `addSeparator`, `addSubmenu`, `clear` / `clearMenu`, `onPopup(void<fp64, fp64>)`, `popupAt(fp64, fp64)`, `setChild(Widget)` |
| `Scrollbar` | `Scrollbar(int64 orientation)` with `HORIZONTAL` / `VERTICAL`, `configure(value, lower, upper, step, page, pageSize)`, `setValue` / `value` / `lower` / `upper` / `pageSize`, `onValueChanged(void<fp64>)` |
| `Scale` | `Scale(int64 orientation)` with `HORIZONTAL` / `VERTICAL`, `configure(value, lower, upper, step)`, `setValue` / `value` / `lower` / `upper` / `step`, `onValueChanged(void<fp64>)` |
| `ProgressBar` | `ProgressBar(int64 orientation)` with `HORIZONTAL` / `VERTICAL`, `setFraction` / `fraction` (0..1), `setText` / `text`, `setShowText` / `showText`, `pulse`, `setPulseStep` / `pulseStep` |
| `SpinButton` | `SpinButton()`, `configure(value, lower, upper, step)`, `setValue` / `value` / `lower` / `upper` / `step`, `onValueChanged(void<fp64>)` |
| `DropDown` | `DropDown()`, `clear`, `append(String)`, `setChoices(list)`, `setSelected` / `selected` / `selectedText` / `size` / `item`, `onSelected(void<int64>)` |
| `Frame` | `Frame(String label)`, `setLabel` / `label`, `setChild` / `remove` |
| `Expander` | `Expander(String label)`, `setLabel` / `label`, `setExpanded` / `expanded`, `setChild` / `remove` |
| `Separator` | `Separator(int64 orientation)` with `HORIZONTAL` / `VERTICAL` |
| `TextView` | `TextView()`, `setText` / `text`, `setEditable` / `editable`, `setWrap` / `wrap`, `onChanged(void<String>)` |
| `Label` | `Label(String text)`, `setText(String)`, `String text()` |
| `Button` | `Button(String label)`, `setLabel(String)`, `String label()`, `setIconName(String)`, `onClicked(void<>)` (focus-on-click off; non-focusable buttons activate on press) |
| `Entry` | `Entry(String text)`, `setText(String)`, `String text()`, `focus()`, `setEditable(bool)`, `onChanged(void<String>)` |
| `CheckButton` | `CheckButton(String label)`, `setLabel(String)`, `String label()`, `setActive(bool)`, `bool active()`, `onToggled(void<bool>)` |
| `ScrolledWindow` | `ScrolledWindow()`, `setChild(Widget)`, `remove(Widget)`, `setPolicy(h, v)` with `POLICY_ALWAYS` / `POLICY_AUTOMATIC` / `POLICY_NEVER` / `POLICY_EXTERNAL`, `setOverlayScrolling(bool)` |
| `Notebook` | `Notebook()`, `appendPage(Widget, String)`, `appendClosablePage(Widget, String, void<>)`, `int64 currentPage()`, `setCurrentPage(int64)`, `int64 pageCount()`, `setPageTitle(int64, String)`, `remove(Widget)`, `onPageChanged(void<>)`, `setBorderedTabs()` |
| `MenuBar` | `MenuBar()`, `int64 addMenu(String)`, `int64 addItem(int64 menu, String label, void<>)`, `int64 addCheckItem(int64 menu, String label, bool initial, void<bool>)`, `int64 addSubmenu(int64 menu, String label)`, `clearMenu(int64 menu)`, `addSeparator(int64 menu)`, `setItemEnabled(int64 item, bool)`, `activateItem(int64 item)`, `setItemChecked(int64 item, bool)`, `bool itemChecked(int64 item)` |

Methods without a listed result return `void`, except signal registration,
which returns `SignalConnection`. Orientation is `Gtk.Box.HORIZONTAL` (`0`) or
`Gtk.Box.VERTICAL` (`1`); spacing is nonnegative and must fit GTK's integer range.
Default window dimensions must be positive and fit that range.
`defaultWidth`/`defaultHeight` return GTK's current default size, which GTK 4
updates when the user resizes an unmaximized window (`0` means unset); use them
to persist window size.
`Window.maximized()` returns the current native maximization state;
`setMaximized(bool)` requests maximize/unmaximize, including before presentation.
The window manager may apply this request asynchronously.
`onFocusChanged` reports GTK's window-active state (`false` on loss).
`Grid` uses zero-based, nonnegative row/column positions and positive spans.
`Entry.setEditable(false)` keeps selection/copy and programmatic updates available.
`ContextMenu` attaches a secondary-button `PopoverMenu` to its owner (any
`Widget`, including `DrawingArea`). `onPopup(void<fp64,fp64>)` fires with
owner-local click coordinates immediately before the menu opens so the app can
`clear()` and rebuild items (status rows, jump targets, and so on).
`addItem` / `addCheckItem` append native menu rows (root or submenu index from
`addSubmenu`); `addSeparator` starts a native divider section; `popupAt(x, y)`
opens the menu programmatically. `setChild` remains for a custom content widget
when needed. Owner disposal tears the menu down. Its capture-phase gesture
suppresses the owner's default popup. For text views that still use
`ContextMenu`, it positions the cursor at the clicked line before opening;
views with line selection enabled select that whole line instead. A right click
inside an existing text selection keeps the selection. Prefer
`GtkSource.View.addContextAction` when the built-in Cut/Copy/Paste menu should
stay and only extra rows are needed.
`appendClosablePage` adds a bordered title/close-icon tab, invoking
the supplied callback without automatically removing the page.
`setBorderedTabs()` applies the same tab border to every page of a notebook.
`Notebook.setScrollable(bool)` adds tab-strip scrolling when titles do not fit,
instead of letting the entire tab strip impose its minimum width on a pane.
After each page change it clears a stuck notebook click gesture so the left
arrow keeps working after a partial right scroll (GTK can drop the matching
release when focus moves into the new page).
`Window.bindShortcut` installs a window-wide shortcut (GTK trigger syntax such
as `<Control>q`) whose callback may close or dispose the window; it is released
with the window. Binding `F10` also clears GTK's default menubar accelerator
(`handle-menubar-accel`) so the first F10 runs the shortcut instead of only
focusing a menubar; use `setMenubarAccel(bool)` / `menubarAccel()` for the same
property explicitly. Page-change callbacks run after GTK changes its current page.
Text accepts managed UTF-8 strings, including empty strings, but not null,
embedded NULs, or invalid UTF-8. Getters return managed copies.

`Window`, `TransientWindow` and `ScrolledWindow` have one child; remove it before
attaching a replacement. `Window` is associated with the `Gtk.Application`;
`TransientWindow` is a standalone top-level. `setTransientFor` establishes the
native transient relationship, with GTK destroy-with-parent enabled. Destroying
the parent destroys the transient and releases its registrations; hiding it
does not. `Box` accepts multiple children. A child must be live and unparented;
windows cannot be children. Self-parenting, cycles, already-parented children,
occupied single-child containers, and removing from the wrong parent are errors.
GTK may internally insert a viewport in a scrolled window; the Cwhip ownership
relationship still refers to the child supplied by the caller.

## DrawingArea

`DrawingArea` is a normal child widget (`GtkDrawingArea`) for custom 2D paint.
Embed it with the same parenting rules as any other widget: `Box.append`,
`Paned.append`, `Notebook.appendPage`, `Grid.attach`, `ScrolledWindow.setChild`,
or `Window.setChild`. Expand it with `setHExpand` / `setVExpand` when it should
fill a panel; call `setContentSize(width, height)` when the canvas should report
a fixed natural size (for example as a `ScrolledWindow` child).

```text
DrawingArea()
void queueDraw()
void setContentSize(int64 width, int64 height)
SignalConnection onDraw(void<int64, int64> action)
SignalConnection onClick(void<int64, fp64, fp64> action)
SignalConnection onDrag(void<int64, fp64, fp64, fp64, fp64> action)
SignalConnection onScroll(void<fp64, fp64, fp64, fp64> action)
enum BUTTON_PRIMARY = 1, BUTTON_MIDDLE = 2, BUTTON_SECONDARY = 3
enum DRAG_BEGIN = 0, DRAG_UPDATE = 1, DRAG_END = 2
void setColor(fp64 r, fp64 g, fp64 b, fp64 a)
void setLineWidth(fp64 width)
void fillRect(fp64 x, fp64 y, fp64 width, fp64 height)
void strokeRect(fp64 x, fp64 y, fp64 width, fp64 height)
void fillCircle(fp64 cx, fp64 cy, fp64 radius)
void strokeCircle(fp64 cx, fp64 cy, fp64 radius)
void strokeLine(fp64 x1, fp64 y1, fp64 x2, fp64 y2)
```

`onDraw` receives the current allocation width and height in pixels. Paint
helpers may run only during that callback; calling them afterward aborts with a
GTK diagnostic. Prefer `f64` float literals for colors and geometry. A later
`onDraw` replaces the previous draw function. `queueDraw` marks the area dirty
so GTK schedules another paint (for example after application state changes).

Pointer callbacks use widget-local coordinates:

- `onClick(button, x, y)` fires on mouse-button release. `button` matches GDK
  (`BUTTON_PRIMARY` / `MIDDLE` / `SECONDARY`). A primary-button drag that moves
  past GTK's drag threshold typically suppresses the click, so pick and pan can
  share the left button.
- `onDrag(phase, start_x, start_y, offset_x, offset_y)` tracks a primary-button
  drag (`DRAG_BEGIN` / `UPDATE` / `END`). Offsets are relative to the press point;
  apps usually keep a pan origin at begin and apply `origin + offset` on update.
- `onScroll(x, y, dx, dy)` reports scroll-wheel / trackpad deltas. `x`/`y` are
  the pointer focus when known (last motion or the scroll event position).

Minimal demo (panel child + clear + circle + click mark):

```cwhip
// test: {"stdout": "", "requires": "gtk"}
import gtk

class Demo {
    Gtk.DrawingArea area
    fp64 markX
    fp64 markY
    void<> quitAction
    void<int64, int64> paintAction
    void<int64, fp64, fp64> clickAction

    void paint(int64 width, int64 height) {
        area.setColor(0.12f64, 0.14f64, 0.20f64, 1.0f64)
        area.fillRect(0.0f64, 0.0f64, fp64(width), fp64(height))
        area.setColor(0.25f64, 0.75f64, 0.40f64, 1.0f64)
        area.fillCircle(fp64(width / 2), fp64(height / 2), 48.0f64)
        area.setColor(0.95f64, 0.55f64, 0.20f64, 1.0f64)
        area.fillCircle(markX, markY, 6.0f64)
    }

    void clicked(int64 button, fp64 x, fp64 y) {
        if (button == Gtk.DrawingArea.BUTTON_PRIMARY) {
            markX = x
            markY = y
            area.queueDraw()
        }
    }

    void quit() {
        Gtk.Application().quit()
    }

    void activate() {
        Gtk.Window window = Gtk.Window("DrawingArea demo")
        window.setDefaultSize(480, 320)
        Gtk.Box layout = Gtk.Box(Gtk.Box.VERTICAL, 0)
        area = Gtk.DrawingArea()
        area.setHExpand(true)
        area.setVExpand(true)
        area.onDraw(paintAction)
        area.onClick(clickAction)
        layout.append(area)
        window.setChild(layout)
        window.present()
        area.queueDraw()
        Gtk.Application().schedule(1500, quitAction)
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.DrawingDemo")
    Demo demo = Demo()
    demo.paintAction = demo.paint
    demo.clickAction = demo.clicked
    demo.quitAction = demo.quit
    app.onActivate(demo.activate)
    app.run()
}
```

See `examples/drawing.cw` for click + drag pan + scroll zoom, custom
`Scrollbar` extents, and `ContextMenu` `onPopup` rebuild together.

### View scroll bars (two supported approaches)

**Path 1 — `ScrolledWindow` + content size.** When the canvas has a natural
size larger than the viewport, wrap the area and let GTK show stock bars:

```cwhip
Gtk.ScrolledWindow scroll = Gtk.ScrolledWindow()
scroll.setPolicy(Gtk.ScrolledWindow.POLICY_AUTOMATIC,
                 Gtk.ScrolledWindow.POLICY_AUTOMATIC)
Gtk.DrawingArea area = Gtk.DrawingArea()
area.setContentSize(2000, 1500)
area.onDraw(paintAction)
scroll.setChild(area)
```

**Path 2 — `Scrollbar` tied to pan/zoom extents.** When zoom is a client-side
transform (content size stays fixed; `onDraw` applies scale/offset), stock
`ScrolledWindow` alone is not enough. Create horizontal/vertical `Scrollbar`
widgets, `configure(value, lower, upper, step, page, pageSize)` from the
current extents, and update the view from `onValueChanged(void<fp64>)`.

```text
Scrollbar(int64 orientation)   // HORIZONTAL = 0, VERTICAL = 1
void configure(fp64 value, fp64 lower, fp64 upper, fp64 step, fp64 page, fp64 pageSize)
void setValue(fp64 value)
fp64 value() / lower() / upper() / pageSize()
SignalConnection onValueChanged(void<fp64> action)
```

Either path (or both) is valid; apps should not assume mouse-only pan.

### DrawingArea ContextMenu hooks

```cwhip
Gtk.ContextMenu menu = Gtk.ContextMenu(area)
menu.onPopup(prepareMenu)   // (x, y) in area coordinates
// inside prepareMenu:
menu.clear()
menu.addItem("Status…", statusAction)
menu.addSeparator()
int64 places = menu.addSubmenu("Known places")
menu.addItem(places, "Planet A", jumpAction)
```

`popupAt(x, y)` opens the same menu without a right-click when the app already
has coordinates (for example from `onClick` with `BUTTON_SECONDARY`).

### Scale (sliders)

`Scale` is a `GtkScale` for continuous or stepped numeric settings (policy
knobs, budgets, discrete 1–10 bands). Orientation matches `Box` / `Paned` /
`Scrollbar` (`HORIZONTAL` = 0, `VERTICAL` = 1). Default range is `0..1` with
step `0.1` until `configure` runs. Page increment follows GTK's
`gtk_scale_new_with_range` convention (`step * 10`). Display digits track the
step size. Prefer `Scale` for settings; use `Scrollbar` for pan/zoom extents.

```text
Scale(int64 orientation)   // HORIZONTAL = 0, VERTICAL = 1
void configure(fp64 value, fp64 lower, fp64 upper, fp64 step)
void setValue(fp64 value)
fp64 value() / lower() / upper() / step()
SignalConnection onValueChanged(void<fp64> action)
```

```cwhip
Gtk.Scale expansion = Gtk.Scale(Gtk.Scale.HORIZONTAL)
expansion.configure(50.0f64, 0.0f64, 100.0f64, 1.0f64)
expansion.onValueChanged(policyChanged)
Gtk.Scale livability = Gtk.Scale(Gtk.Scale.VERTICAL)
livability.configure(5.0f64, 1.0f64, 10.0f64, 1.0f64)
```

See `examples/scale.cw`.

### ProgressBar

`ProgressBar` is a `GtkProgressBar` for determinate fraction (0..1) or
indeterminate `pulse` feedback (build/download/ETA chrome, long jobs).
Orientation matches `Box` / `Paned` / `Scale` (`HORIZONTAL` = 0,
`VERTICAL` = 1). Defaults are fraction `0`, `showText` false, empty text, and
pulse step `0.1`. With `showText` true and empty text, GTK may display a
percentage; `setText` supplies a custom overlay label. `pulse` advances the
block by `pulseStep` (must be in `(0.0, 1.0]`). Out-of-range fractions abort.

```text
ProgressBar(int64 orientation)   // HORIZONTAL = 0, VERTICAL = 1
void setFraction(fp64 fraction) / fp64 fraction()
void setText(String text) / String text()
void setShowText(bool show) / bool showText()
void pulse()
void setPulseStep(fp64 step) / fp64 pulseStep()
```

```cwhip
Gtk.ProgressBar develop = Gtk.ProgressBar(Gtk.ProgressBar.HORIZONTAL)
develop.setHExpand(true)
develop.setShowText(true)
develop.setText("developing…")
develop.setFraction(0.35f64)
Gtk.ProgressBar unknown = Gtk.ProgressBar(Gtk.ProgressBar.HORIZONTAL)
unknown.setPulseStep(0.15f64)
unknown.pulse()
```

See `examples/progress.cw`.

### SpinButton

`SpinButton` is a `GtkSpinButton` for bounded integer or stepped numeric entry
(counts, 0–100 percents, discrete ranges). Prefer it over free-text `Entry` when
the value has hard bounds; prefer `Scale` when a continuous slider is the better
control. Default range is `0..100` with step `1` until `configure` runs. Page
increment is `step * 10`. Display digits track the step size (same heuristic as
`Scale`).

```text
SpinButton()
void configure(fp64 value, fp64 lower, fp64 upper, fp64 step)
void setValue(fp64 value)
fp64 value() / lower() / upper() / step()
SignalConnection onValueChanged(void<fp64> action)
```

```cwhip
Gtk.SpinButton hulls = Gtk.SpinButton()
hulls.configure(1.0f64, 1.0f64, 12.0f64, 1.0f64)
hulls.onValueChanged(hullsChanged)
```

See `examples/spin.cw`.

### DropDown

`DropDown` is a `GtkDropDown` over a `GtkStringList` for enum and id pickers.
Build the model with `clear`/`append` or `setChoices(list)` (a list of
`String`). `selected()` is the 0-based index, or `-1` when nothing is selected;
`selectedText()` returns the choice string (or `""`). `setSelected(-1)` clears
the selection. `onSelected` reports the new index (including `-1`).

```text
DropDown()
void clear() / append(String) / setChoices(list)
void setSelected(int64 index) / int64 selected()
String selectedText() / int64 size() / String item(int64 index)
SignalConnection onSelected(void<int64> action)
```

```cwhip
Gtk.DropDown role = Gtk.DropDown()
role.setChoices(["neutral", "conqueror", "pirate", "trader", "hermit"])
role.setSelected(0)
role.onSelected(rolePicked)
```

See `examples/dropdown.cw`.

### Frame, Expander, Separator

Layout helpers for denser dialogs:

- `Frame(String label)` — decorative titled border around one child (`setChild`).
- `Expander(String label)` — collapsible section (`setExpanded` / `expanded`,
  `setChild`). Starts collapsed.
- `Separator(int64 orientation)` — horizontal or vertical divider
  (`HORIZONTAL` = 0, `VERTICAL` = 1).

```cwhip
Gtk.Frame group = Gtk.Frame("Budget")
group.setChild(budgetBox)
Gtk.Expander more = Gtk.Expander("Advanced")
more.setExpanded(false)
more.setChild(advancedBox)
root.append(Gtk.Separator(Gtk.Separator.HORIZONTAL))
```

### TextView

`TextView` is a plain multiline `GtkTextView` for compose/digest panes (not
syntax-aware; use the `sourceview` package for editors). Defaults: editable,
word wrap on. `onChanged` delivers the full buffer text.

```text
TextView()
void setText(String) / String text()
void setEditable(bool) / bool editable()
void setWrap(bool) / bool wrap()
SignalConnection onChanged(void<String> action)
```

```cwhip
Gtk.TextView body = Gtk.TextView()
body.setText("Hello\nworld")
body.onChanged(bodyChanged)
```

See `examples/textview.cw`.

**Deferred (not in this release):** dashed strokes and draw-text helpers.

Expansion uses GTK's actual `hexpand`/`vexpand` layout properties. For an editor,
expand the notebook, scrolled window and source widget vertically and horizontally
so they receive the window's available viewport, rather than only one line's
natural height. `focus()` requests keyboard focus; the target must be in a
presented window to receive it.

## Menus and asynchronous file dialogs

`MenuBar` is a real `GtkPopoverMenuBar` backed by `GMenu` and `GSimpleAction`.
`addMenu(label)` returns a zero-based submenu index. `addItem(menu, label, action)`
returns a positive, unique item token scoped to that menu bar. Actions retain
their typed callback receivers until menu disposal or application shutdown.
`setItemEnabled` updates the actual GTK action state. `activateItem` invokes
that same action, including GTK's disabled-action check; disabled items do not
invoke callbacks. An action may dispose its own menu/window or shut down.
`addSeparator(menu)` starts a new menu section, so later items in that menu are
drawn after a separator. `addCheckItem` adds a boolean action drawn as a check
item. Its callback receives the new state. `setItemChecked` updates that state
without invoking the callback. `activateItem` toggles a check item and does
invoke the callback; a disabled item does neither.

```text
Gtk.FileDialog(Window parent, bool save, String initialPath,
               void<String> result)
void cancel()
bool pending()
```

Construction shows a modal, parented `GtkFileDialog` asynchronously:
`save=false` opens an existing file; `save=true` chooses a save destination.
An empty initial path uses GTK's default location. A directory selects the
starting folder; a filename selects the open file or initializes the save
folder/name. Local selections return filesystem paths. Nonlocal selections
return their URI, allowing applications to explicitly report unsupported
locations rather than silently treating acceptance as cancellation.

User acceptance invokes the rooted typed callback once with a copied managed
path or URI. User cancellation invokes it once with `""`. Save choosers
use GTK 4's built-in asynchronous overwrite confirmation (including native
platform/portal equivalents). A destination is delivered only after replacement
has been accepted. Declining replacement leaves the chooser open, allowing
another name or cancellation; the binding does not add a second confirmation.

`cancel()` is idempotent programmatic cancellation and **does not invoke** the
result callback. Parent destruction/disposal and application shutdown likewise
cancel pending choosers and release their callback roots without invocation.
`pending()` becomes false before the result handler runs and remains usable
after cancellation or shutdown. Dropping a dialog variable does not cancel it.
Callbacks may collect, retain their result, open another chooser, dispose the
parent, or shut down. GTK's asynchronous request completes before the Cwhip
result handler runs, using a one-shot GUI idle dispatch; no nested main loop
or blocking wait is used.

```text
Gtk.FileDialog(Window parent, String initialPath, void<list> results)
```

This open-only constructor enables multiple selection. Acceptance invokes
`results` once with a list of every selected path or URI (in chooser order);
cancellation invokes it once with an empty list. A file `initialPath` starts in
that file's folder. Cancellation, disposal and shutdown rules are the same as
for the single-result constructor.

```text
Gtk.AlertDialog().show(Window parent, String message, String detail)
```

`show` presents a modal `GtkAlertDialog`, transient for `parent`, with a primary
message, secondary detail text and a single Close button. It returns
immediately and needs no callback; the binding keeps no reference to the alert.

The folder-selection overload is:

```text
Gtk.FileDialog(Window parent, String initialPath, void<String> folder)
```

It uses `gtk_file_dialog_select_folder`, with the same parent,
asynchronous delivery, accept/cancel, URI and lifetime contracts as the existing
file constructors. The overload preserves existing open/save/multiple APIs.
All constructors use cancellable GTK asynchronous requests. Programmatic
cancellation unlinks the pending token and releases the callback root immediately;
native request storage remains alive until GTK delivers its completion. A late
completion after cancellation, parent teardown or shutdown never invokes Cwhip
code. Folder selection is not treated as an open-file request.

## Trees and asynchronous directory enumeration

`Paned` is a draggable two-child splitter (`Paned()` is horizontal; pass
`Paned.VERTICAL` for top/bottom). `append` attaches the
start child first, then the end child. A third child is an error.
`setPosition` accepts a nonnegative GTK integer pixel position, and `position()`
returns the current divider position. The start side keeps its requested width
on window resize and cannot shrink past its minimum (so a sidebar cannot be
dragged to zero). The end side grows with the window and may shrink so the
start side can widen. Use `Widget.setWidthRequest` on the start child when a
larger floor than the child's natural minimum is needed.

```text
Gtk.Tree(void<int64> request, void<int64> activate)
void add(int64 parent, int64 id, String label, String icon, bool expandable,
         String value, int64 data)
void clear(int64 parent)
void setExpanded(int64 id, bool expanded)
String value(int64 id)
int64 data(int64 id)
int64 findValue(String value)
int64 childCount(int64 parent)
bool expanded(int64 id)
```

`Tree` is a virtualized `GtkListView`/`GtkTreeListModel` with `GtkTreeExpander`
rows and symbolic icon names. IDs must be positive and unique among live rows;
parent `0` denotes its roots. Values and integer data are generic, native-owned
row metadata, copied from the caller, not filesystem policy. `request(id)`
runs when an expandable row expands (possibly again on rebinding);
applications should guard already-started loads. Collapsed rows do not request
population merely to render their expansion arrow. `activate(id)` runs for
leaves on double-click/Enter by default; `setSingleClickActivate(true)` enables
single-click activation. Directory activation toggles expansion.
`clear(parent)` removes its descendants, invalidating their IDs.
`setExpanded` requires a visible, expandable row; expand its ancestors first.
`expanded(id)` reports whether a live row is currently expanded (false
when it is not visible). `findValue` returns the smallest matching live ID or `0`; `childCount` counts
immediate children, including any loading/error placeholders. All other row
methods require a live ID. Roots/callbacks are released on widget disposal and
shutdown, including disposal from within a callback.

```text
Gtk.DirectoryScan(Gtk.Tree owner, String path, bool hidden,
                  void<int64, String> result)
Gtk.DirectoryScan(Gtk.Tree owner, String path, bool hidden, String root,
                  String excludes, void<int64, String> result)
void cancel()
void append(Gtk.Tree owner, int64 parent, int64 firstId, int64 count, String icons)
```

Enumeration and sorting run on a native worker without managed-runtime or GTK
access. On the GUI owner thread, `result(count, "")` delivers a batch of up to
64 entries, at 5ms intervals. During that callback, `append` copies the current
batch into its owning Tree, assigning consecutive IDs starting at `firstId`.
The application chooses the parent, IDs and icons, without allocating a
managed object/path for every file. Ignoring a batch skips those rows.
`append` is valid only for that active batch, with a positive count no larger
than the delivered count; any remaining entries in that batch are skipped.

Rows have local UTF-8 paths as their `value` and kind as their integer `data`:
`0` (regular file), `1` (directory), `2` (symlink), or `3` (other).
Directories are expandable; other kinds are leaves. `icons` is a newline-separated
set of `key=icon-name` rules, with required defaults `0` through `3` and
optional filename suffixes beginning with `.`; the first matching suffix
overrides the regular-file default. These rules are supplied by the application,
not hardcoded editor policy in the native binding.

Dot-prefixed entries are omitted when `hidden=false`; directories sort first,
then UTF-8 names in byte order. Child symlinks are not followed. An explicitly
selected root may itself be a symlink. A final `result(-1, error)` reports
completion; empty error means success. Read failures or invalid-UTF-8 filenames
report a nonempty error and no batches.

The filtered constructor additionally omits entries matching `excludes`, a
newline-separated list of GLib `g_pattern_match_simple` globs (`*`, `?`).
A pattern without `/` is matched against the entry name; a pattern with `/`
is matched against the entry's path relative to `root` (which should be an
ancestor of `path`). Empty `excludes` filters nothing. Excluded directories are
never enumerated. Pattern validation is the application's responsibility.

Dropping the scan variable does not cancel it. Idempotent `cancel`, owner Tree
disposal and shutdown release the callback root without further results.
An active callback can cancel itself or shut down; registration release waits
until it unwinds. The worker retains only native memory and a cancellable,
so cancellation does not block the GUI waiting for filesystem I/O. Applications
remain responsible for generation checks and for their loading/error rows.

## Source editing

Configure `-DCWHIP_GTK_SOURCEVIEW=ON` together with GTK to enable `import sourceview`
and `GtkSource.View`. `widget()` supplies its `Gtk.SourceViewWidget` for normal
parenting and expansion. `setMonospace(bool)` selects GTK's text-view
monospaced-font mode without changing the font of other widgets. Besides text,
modified state, search/replace, language,
cursor and shortcut operations, the editor exposes:

```text
bool canUndo()
bool canRedo()
bool hasSelection()
void undo()
void redo()
void cut()
void copy()
void paste()
void selectAll()
void focus()
void setEmojiMenu(bool enabled)
void setCursor(int64 line, int64 column)
void centerCursor(int64 line, int64 column)
void setEditable(bool editable)
void setRightMargin(bool show, int64 column)
bool rightMarginShown()
int64 rightMarginColumn()
int64 selectionStartLine()
int64 selectionStartColumn()
int64 selectionEndLine()
int64 selectionEndColumn()
void beginUserAction()
void endUserAction()
void insertText(int64 line, int64 column, String text)
void deleteRange(int64 startLine, int64 startColumn, int64 endLine, int64 endColumn)
void replaceRange(int64 startLine, int64 startColumn, int64 endLine, int64 endColumn, String text)
void selectRange(int64 startLine, int64 startColumn, int64 endLine, int64 endColumn)
```

`setCursor` places the insertion cursor at a 1-based line and character column
and scrolls it into view. Values are clamped to the buffer: lines below 1 or past
the end select the first/last line, and columns past the end of the line select
the line end. It matches the 1-based `line()`/`column()` getters.
`setRightMargin` draws a visible column guide (custom snapshot overlay so it
stays visible when the style scheme omits a right-margin color); `column` is
clamped to 1–512. Selection edge getters are 1-based; with no selection both
edges are the insertion cursor. `insertText` / `deleteRange` / `replaceRange` edit without
replacing the whole buffer (`replaceRange` is one undo group). Wrap multi-step
edits in `beginUserAction` / `endUserAction`. `selectRange` sets the selection
bounds with the same clamping.

`Gtk.Clipboard.setText` / `text()` write the display clipboard and keep a
same-process cache. `text()` returns that cache (GDK clipboard reads are
asynchronous and are not polled here).

`setSelectedLinesEdit(true)` installs a capture-phase key filter: when the
selection spans two or more lines, printable characters, Backspace, and Delete
apply at the selection-start column on each selected line as one undo group.
Tab/Enter and modified keys are left to other handlers. This is not true
multi-cursor editing.
`centerCursor` uses the same clamping but vertically centers the insertion mark
in the viewport (subject to the beginning/end of the buffer), without a
preceding scroll-to-edge. `setEditable(false)` prevents user edits while
retaining selection/copy and programmatic buffer updates.

Undo/redo state and selection query the actual text buffer. Clipboard operations
use GTK's display clipboard; paste is asynchronous and obeys text-view editability.
`setEmojiMenu(false)` hides Insert Emoji using GTK's no-emoji input hint while
retaining native editing items; the default remains enabled for other applications.
`setText` follows GTK's whole-buffer replacement semantics: it is irreversible
and clears prior undo/redo history. It is appropriate for loading/resetting a
document; typing, clipboard edits and `replaceNext` create undoable user edits.
Selection and edits emit the existing buffer/cursor signals, so menus can refresh
their action state. `onChanged` also forwards `can-undo`/`can-redo` property
notifications, which occur after GTK has updated its undo manager.
`onCursorMoved` forwards insertion/selection-bound mark changes and
`has-selection` notifications. Handlers may therefore run more than once for
one edit; query current state rather than counting emissions. Each returned
connection token disconnects the whole grouped subscription. These methods
share the normal GUI-thread lifetime rules.

Read-only line-oriented interactions and source marks are also supported:

```text
void setLineSelection(bool enabled)
int64 onLineActivated(void<int64> action)
void setMarkStyle(String category, String icon, String background)
void setMarkStyle(String category, String icon, String background, bool lineHighlight)
void setAutoIndent(bool enabled)
void addLineMark(String category, int64 line)
void addLineMarkTooltip(String category, int64 line, String tooltip)
void clearLineMarks(String category)
void addContextAction(String label, void<> action)
```

`onLineActivated` handles a primary single click in the capture phase, positions
the cursor (or selects the line when `setLineSelection(true)`), and reports the
one-based line number without claiming the click sequence (so a lost release
cannot stick the capture gesture and swallow a later toolbar click). Double
clicks retain normal text selection behavior.
The returned signal token can be disconnected; widget disposal disconnects
controller callbacks and releases their receivers, including during invocation.
`setLineSelection` also applies to a text view's `ContextMenu` right click.
These APIs do not turn arbitrary text views into list models.

Source marks use GtkSourceView categories, with a GTK icon name and CSS-parsable
background color configured by `setMarkStyle` (gutter tint and optional line tag).
Marks always show in the gutter.
The three-argument form also underlines and tints the line; pass
`lineHighlight=false` for a gutter icon only (no gutter tint or line color).
`setAutoIndent` enables Enter-key indent that copies the previous line's leading
whitespace and adds one indent level when that line ends with `{` or `[`
(and splits `{|}` / `[|]` across three lines). Independent of `configure`.
`addLineMark` uses one-based lines, deduplicates marks in that category at a
line, and ignores lines beyond the buffer's end. `addLineMarkTooltip` does the
same and stores hover text shown for the gutter mark and for the line itself.
`clearLineMarks` removes only that category and its line styling. Empty
categories, invalid colors and nonpositive lines are programming errors.
`addContextAction` appends a labeled row to the view's native right-click
menu (`gtk_text_view_set_extra_menu`) without replacing Cut, Copy, Paste, or
other built-in entries.

`configure(String font, int64 size, int64 tabs, bool spaces, bool numbers, bool wrap,
bool highlight)` applies a per-view font family/point size, tab width,
space insertion, line numbers, word/character wrapping, and current-line
highlighting without replacing the buffer or language. It keeps monospace mode
enabled. Size must be 6-72 and tabs 1-16; validate user input before calling it.
`setShowWhitespace(true)` enables the space drawer for spaces, tabs, and
non-breaking spaces; `setShowLineEnds(true)` draws newline marks. Either flag
enables the drawer; both false disables it. `setShowIndentMarkers(true)` draws
a vertical guide at each tab-width indent level in the leading whitespace.
Neither call changes the font, tab width, or line numbers.
`clearShortcuts()` removes all shortcuts installed through `bindShortcut`,
including their callback roots, without changing GTK's native editing bindings.
Removal/disposal during an active shortcut callback defers releasing that
callback until invocation unwinds.

Shortcut callbacks registered on a view may dispose that view, its window or
the application, or shut down (for example a Close or Quit command). A binding
released while its own callback is running is marked released and its receiver
root is dropped only after the callback returns; later activations are ignored.

Search and replace take an option sum of `GtkSource.View.CASE_SENSITIVE`,
`WHOLE_WORDS`, `IN_SELECTION` and (for `findWith` only) `BACKWARD` (0 is case-insensitive, substring, whole
buffer; `find`/`replaceNext` are the zero-option forms):

```text
bool findWith(String query, int64 options)
bool replaceWith(String query, String replacement, int64 options)
int64 replaceAll(String query, String replacement, int64 options)
bool captureSearchScope()
bool hasSearchScope()
String selectedText()
```

`findWith` selects the next match after the current selection, wrapping once;
with `BACKWARD` it selects the previous match before the selection start.
`replaceWith` replaces the selection when it is a match, otherwise finds and
replaces the next one. `replaceAll` is a single undoable user action, never
rescans inserted text, and returns the replacement count. Whole words require
non-word characters (or buffer bounds) on both sides of a match. `IN_SELECTION`
limits the search to the scope recorded by `captureSearchScope()`: the current
selection is stored as text marks whose gravities keep the range covering
replaced text as the buffer changes. Capturing with no selection clears the
scope; a selection equal to the last match keeps the existing scope, so repeated
Find does not shrink it. With `IN_SELECTION` but no scope, searches fail.

### Language definitions

Views start as plain text: no syntax highlighting. Line numbers, auto-indent
and four-space indentation are independent of language.

```text
bool setLanguage(String id)          // "" selects plain text
String language()                    // current id, "" when plain
String GtkSource.Content().languageFor(String path)
bool GtkSource.Content().isText(String data)
```

The language protocol uses standard GtkSourceView 5 `.lang` files:

1. A language is registered from every directory on the language-manager
   search path. That path starts with GtkSourceView's default directories.
   When those directories contain no `.lang` files, the newest installed
   spec directory on the system data path is added (`gtksourceview-5`,
   `libgedit-gtksourceview-300`, `gtksourceview-4`, then
   `gtksourceview-3.0`). The sourceview package's `language-specs` directory
   is searched first, so the bundled definition wins for `*.cw`. The file
   name must equal the `id` attribute of its `<language>` element.
   `setLanguage` returns false for an id that is not registered and leaves
   the view unchanged.
2. File association comes from the definition's `globs` and `mimetypes`
   metadata, through GtkSourceView's language manager. `languageFor(path)`
   matches the file name only (no content sniffing) and returns `""` for
   untitled paths, unknown extensions, or unregistered languages.
3. `cwhip.lang` is the bundled definition (`*.cw`). Other languages come from
   the GtkSourceView specs installed on the host, such as C and Python.
   An application selects one with `languageFor` or `setLanguage`.

`isText` returns false for data containing NUL bytes. Cwhip strings are always
valid UTF-8, so `File.readAll` raises on undecodable input; applications should
treat that as a binary/non-text file.

## Preference support primitives

`Gtk.Font().isMonospace(String family)` accepts the generic `monospace` and
installed Pango monospace families, rejecting control characters and other
families. It does not select an application-wide font.

`Gtk.Keyboard().normalize(String trigger)` returns GTK's canonical spelling for
one key-value trigger, or `""` for invalid/unsupported syntax (including compound
alternative triggers). Use this result to compare conflicts.
`int64 record(Gtk.Entry entry, void<String> result)` captures the next
non-modifier key combination at the entry; Escape delivers `""`. The result
does not change the entry itself. `bool cancel(int64 token)` disconnects and
removes the recorder, and is safe inside its callback. It remains registered
until cancelled, its entry is destroyed, or application shutdown; callers must
cancel after receiving a result and coordinate which entry is recording.

`Gtk.Config` exposes small TOML/persistence primitives for Cwhip-written
settings models, not a settings framework:

| Operation | Result/contract |
| --- | --- |
| `String validate(String text)` | `""` for valid TOML; otherwise a parse/scalar error. Encoded NUL strings are unsupported. |
| `String fileStatus(String path)` | `""` for an existing path, `missing` only for file-not-found, or an explicit stat/broken-symlink error. |
| `String value(String text, String section, String key)` | After validation: `""` for absent, `s` plus decoded string, `i` plus decimal integer, `btrue`/`bfalse`, `t` for a table, `x` for another type. Empty section addresses the root. |
| `String key(String text, String section, int64 index)` | Zero-based key enumeration; `""` at the end or for an absent table. |
| `String quote(String text)` | A TOML-escaped basic string literal. |
| `String item(String text, String section, String key, int64 index, String field)` | After validation: a tagged value (same tags as `value`) for zero-based element `index` of array `section.key`, or with nonempty `field`, that key of a table element (`""` if absent, `x` if the element is not a table). `""` past the end or for a missing array. |
| `int64 arraySize(String text, String section, String key)` | Array element count, or `-1` for a missing/non-array value. |
| `String remove(String text, String section, String key)` | Validated TOML with one key removed (empty section addresses the root); other values are kept and serialized as by `merge`. |
| `String merge(String original, String updates)` | Both inputs must be validated TOML; recursively overlays updates and serializes, preserving unrelated values but not comments/formatting. |
| `void save(String path, String text, String expected, void<String> result)` | Asynchronously loads the local file, checks expected previous contents, then atomically replaces using its ETag where supported. Expected `""` allows a missing first-run file. Result is `""` on success, or an explicit I/O/concurrent-edit error. The caller creates the parent directory and bounds/validates the data. |
| `String saveNow(String path, String text, String expected)` | Synchronous counterpart for small bounded state snapshots that must finish before window teardown. Uses the same content/ETag guard and atomic private-file replacement. Returns `""` on success or an explicit error; callers must report it. Bounds/validation and parent-directory creation remain the caller's responsibility. |
| `void flush()` | GUI-owner only. Blocks until every in-flight `save` completion callback has run (including coalesced follow-up saves). Use when a caller must observe `save` side effects before continuing on the same turn. |

Save callback roots and copied bytes survive asynchronous I/O. Shutdown drains
pending operations without invoking their callbacks after teardown. `flush()`
is the same drain for live code that still needs those callbacks. These
operations, except pure TOML conversion, share GTK's GUI-owner rules. The TOML
parser is vendored MIT-licensed
[tomlc99](https://github.com/cktan/tomlc99/tree/29076dfd095bbbbd50a3c1b2760d29f4b83e74ac)
(`toml.c`/`toml.h`, with license headers retained); no runtime parser was
available in the repository. The compiler's package-manifest-specific parser
is not used as a general user-settings parser.

## Ownership, aliases, and disposal

The package sinks floating GObject references and owns an independent native
reference for every concrete wrapper; GTK's parent/application references remain
GTK's responsibility. Its private records and retained, non-invoked receiver
callbacks keep wrappers alive until disposal or shutdown. Dropping a Cwhip
variable does **not** dispose its native object. Detached widgets remain
application-owned resources until explicitly disposed or shut down.

`dispose()` is explicit, GUI-thread-only and idempotent. It disconnects the
source's signals, recursively disposes its **currently attached Cwhip children**,
detaches from its parent, destroys windows, and releases owned references.
`remove(child)` detaches without disposing: the child remains usable and can
be attached elsewhere. A child disposed directly is removed from its parent.
Closing/destroying a native application window also invalidates its wrapper and
recursively disposes attached children, even when an external GObject reference
keeps native storage alive. A prevented close leaves the entire tree live.

Assignments and base casts are aliases to the same wrapper/record, not independent
owners. Disposing through any alias invalidates all aliases. There is no public
API for manufacturing another owner from a raw native pointer. All operations
after disposal fail clearly, except repeat `dispose()` and the GUI-only
`disposed()` query. After application shutdown, every widget reports disposed.
Disposed records are tombstones until shutdown; private integer identities are
never reused and are never dereferenced as native pointers.

The native ownership contract allows only one `Widget` base per managed object.
Multiple widget base subobjects are rejected during construction, so signal
registration cannot silently select another widget base. The shipped hierarchy
does not provide a general custom/native-widget subclass framework.

No widget, connection, or application GC finalizer performs GTK teardown.
Use `dispose()`, not Cwhip's language-level `destroy()`, for GUI lifetime.
Custom subclass finalizers must not call GTK: GC can run on a worker, and native
teardown is exclusively a GUI-thread operation.

## Typed signals

`connection.disconnect()` returns true on the first live disconnection and false
thereafter. `connection.connected()` reports current state; both are GUI-only
and remain usable after source disposal or application shutdown.
Ignoring/dropping the returned connection does not disconnect the handler.
Typed `SignalConnection(source, action)` constructors are also available for
`Application`, `Button`, `Entry`, `Window`, and `CheckButton`, with the same
callback signatures as their registration methods. They expose no native
handle or connection-token constructor.

Handlers receive Cwhip values, never raw GTK instance pointers:
`Button` invokes `void<>`; `Entry` invokes `void<String>`
with a copied, rooted managed string; `CheckButton` invokes
`void<bool>` with its current active state. A
`Window` close-request handler returns true to prevent closing and false to
allow GTK's default close action. GTK's native signal ordering/accumulators
still apply when multiple handlers are connected.

Connections retain callback receivers until disconnection/source disposal/
shutdown and the last in-flight invocation **and** GLib closure user have
finished. Disconnecting or disposing inside a handler, including nested
emissions, is supported. A disconnected handler does not receive later emissions.
The native text pointer is copied before entering Cwhip; callbacks can allocate,
collect, retain the string, and mutate/dispose the source without invalidating
the payload. GTK may coalesce or suppress recursive editable changes; no extra
synthetic notifications are promised.

## Runnable sample

This headless-tested program builds its hierarchy during activation and uses a
typed changed signal to update a label. The posted finish action makes the
documentation program terminate automatically. For an interactive editor with
a checkbox, scrolled content, and a close button, see `examples/gtk.cw`
(run without `--test`).

```cwhip
// test: {"stdout": "Hello GTK", "requires": "gtk"}
import gtk

class Demo {
    Gtk.Window window
    Gtk.Entry entry
    Gtk.Label label
    void<String> changedAction
    void<> finishAction

    void activate() {
        window = Gtk.Window("Cwhip")
        Gtk.Box layout = Gtk.Box(Gtk.Box.VERTICAL, 8)
        window.setChild(layout)
        entry = Gtk.Entry("")
        label = Gtk.Label("")
        layout.append(entry)
        layout.append(label)
        entry.onChanged(changedAction)
        window.present()
        Gtk.Application().post(finishAction)
    }
    void changed(String text) { label.setText(text) }
    void finish() {
        entry.setText("Hello GTK")
        print(label.text())
        window.close()
    }
}

start {
    Gtk.Application app = Gtk.Application("org.cwhip.Demo")
    Demo demo = Demo()
    demo.changedAction = demo.changed
    demo.finishAction = demo.finish
    app.onActivate(demo.activate)
    app.run()
    app.shutdown()
}
```

## Threading and native boundaries

All creation, properties, parenting, signals, queries and disposal require the
designated registered GUI thread and its managed lock. Worker threads cannot
call widget methods, disconnect signals or query GUI state directly; use `post`.
Callable source types use `R<P...>`, such as `void<>` and `void<String>`.
The native callback bridge retains the canonical ABI signature string
`callback<R(P...)>` and exact context-first adapters.
Package-native forwarding, callback transfers, and thread/lock checks
are private implementation machinery, not public raw-pointer APIs.

`run()` releases the managed lock across `g_application_run()` so workers progress
while GTK waits. Every native-to-Cwhip signal acquires the lock with
`cwhip_runtime_managed_enter()` and restores it with `managed_leave(acquired)`.
Synchronous/nested reentry preserves lock ownership; foreign threads are never
registered implicitly. One-shot worker posts prepare a rooted, non-invocable
`CwhipCallbackTransfer`; GUI dispatch accepts it into a fresh GUI-owned context.
Cancellation consumes the transfer without invocation.

Native contract violations print a diagnostic and abort; null managed receiver
access follows the existing Cwhip runtime diagnostic. Exceptions escaping any
native callback abort **inside** the bridge, never unwind through GTK or fabricate
a return value. Catch recoverable exceptions inside handlers. Bridge ownership
checks are unchanged.

The suite uses real GTK/Xvfb and isolated session buses, compiled and installed
consumers, GC/reentry/misuse cases, optional documentation/examples, and ASan/UBSan.
`tests/test_gtk_bindings.py` additionally drives real native chooser responses,
overwrite acceptance/decline, callback GC and cancellation/teardown, menu actions,
and actual multiline source-widget allocations before and after window resize.
Its private fixture is not shipped in the package.
See [TESTING.md](TESTING.md). Styling, broad dialog/model coverage, input events,
arbitrary native-widget adoption, file-open/command-line activation, and broad GTK
property coverage are not implemented in this release. `DrawingArea` provides a
custom-paint surface with click/drag/scroll coordinates, `Scrollbar` /
`ScrolledWindow` view chrome, and DrawingArea `ContextMenu` hooks; `Scale`
covers numeric sliders; `ProgressBar` covers determinate fraction and pulse
feedback; `SpinButton` / `DropDown` cover bounded numeric entry and string
pickers; `Frame` / `Expander` / `Separator` / `TextView` cover denser dialog
layout and plain multiline text. Richer path/text paint APIs remain open.
