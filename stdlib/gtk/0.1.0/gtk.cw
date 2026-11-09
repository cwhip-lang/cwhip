namespace Gtk {
    class Config {
        String validate(String text)
        String fileStatus(String path)
        String value(String text, String section, String key)
        String key(String text, String section, int64 index)
        String quote(String text)
        String merge(String original, String updates)
        String remove(String text, String section, String key)
        String item(String text, String section, String key, int64 index, String field)
        int64 arraySize(String text, String section, String key)
        void save(String path, String text, String expected, void<String> result)
        String saveNow(String path, String text, String expected)
        void flush()
    }
    String Config.validate(String text) from "cwhip_gtk_config_validate"
    String Config.fileStatus(String path) from "cwhip_gtk_config_file_status"
    String Config.value(String text, String section, String key) from "cwhip_gtk_config_value"
    String Config.key(String text, String section, int64 index) from "cwhip_gtk_config_key"
    String Config.quote(String text) from "cwhip_gtk_config_quote"
    String Config.merge(String original, String updates) from "cwhip_gtk_config_merge"
    String Config.remove(String text, String section, String key) from "cwhip_gtk_config_remove"
    String Config.item(String text, String section, String key, int64 index, String field)
        from "cwhip_gtk_config_item"
    int64 Config.arraySize(String text, String section, String key) from "cwhip_gtk_config_array_size"
    void Config.save(String path, String text, String expected, void<String> result)
        from "cwhip_gtk_config_save"
    String Config.saveNow(String path, String text, String expected) from "cwhip_gtk_config_save_now"
    void Config.flush() from "cwhip_gtk_config_flush"

    class Keyboard {
        String normalize(String trigger)
        int64 record(Entry entry, void<String> result)
        bool cancel(int64 token)
    }
    String Keyboard.normalize(String trigger) from "cwhip_gtk_keyboard_normalize"
    int64 Keyboard.record(Entry entry, void<String> result) from "cwhip_gtk_keyboard_record"
    bool Keyboard.cancel(int64 token) from "cwhip_gtk_keyboard_cancel"

    class Font {
        bool isMonospace(String family)
    }
    bool Font.isMonospace(String family) from "cwhip_gtk_font_is_monospace"

    // Display clipboard helpers. setText updates the system clipboard and a
    // same-process cache; text() returns that cache (GDK reads are async).
    class Clipboard {
        void setText(String text)
        String text()
    }
    void Clipboard.setText(String text) from "cwhip_gtk_clipboard_set_text"
    String Clipboard.text() from "cwhip_gtk_clipboard_text"
    class Application {
        private:
        void _create(String id)
        Application _self()
        public:
        Application() {}
        Application(String id) { _create(id) }
        void initialize()
        String id()
        SignalConnection onActivate(void<> action) {
            return(SignalConnection(_self(), action))
        }
        void run()
        void quit()
        void shutdown()
        int64 post(void<> action)
        int64 schedule(int64 milliseconds, void<> action)
        bool cancel(int64 token)
    }

    class SignalConnection {
        private:
        int64 _token
        int64 _activate(Application source, void<> action)
        int64 _click(Button source, void<> action)
        int64 _changed(Entry source, void<String> action)
        int64 _close(Window source, bool<> action)
        int64 _close(TransientWindow source, bool<> action)
        int64 _toggled(CheckButton source, void<bool> action)
        int64 _pageChanged(Notebook source, void<> action)
        int64 _focusChanged(Window source, void<bool> action)
        int64 _draw(DrawingArea source, void<int64, int64> action)
        int64 _click(DrawingArea source, void<int64, fp64, fp64> action)
        int64 _drag(DrawingArea source, void<int64, fp64, fp64, fp64, fp64> action)
        int64 _scroll(DrawingArea source, void<fp64, fp64, fp64, fp64> action)
        int64 _popup(ContextMenu source, void<fp64, fp64> action)
        int64 _valueChanged(Scrollbar source, void<fp64> action)
        int64 _valueChanged(Scale source, void<fp64> action)
        int64 _valueChanged(SpinButton source, void<fp64> action)
        int64 _selected(DropDown source, void<int64> action)
        int64 _changed(TextView source, void<String> action)
        bool _disconnect(int64 token)
        bool _connected(int64 token)
        public:
        SignalConnection(Application source, void<> action) {
            _token = _activate(source, action)
        }
        SignalConnection(Button source, void<> action) {
            _token = _click(source, action)
        }
        SignalConnection(Entry source, void<String> action) {
            _token = _changed(source, action)
        }
        SignalConnection(Window source, bool<> action) {
            _token = _close(source, action)
        }
        SignalConnection(TransientWindow source, bool<> action) {
            _token = _close(source, action)
        }
        SignalConnection(CheckButton source, void<bool> action) {
            _token = _toggled(source, action)
        }
        SignalConnection(Notebook source, void<> action) {
            _token = _pageChanged(source, action)
        }
        SignalConnection(Window source, void<bool> action) {
            _token = _focusChanged(source, action)
        }
        SignalConnection(DrawingArea source, void<int64, int64> action) {
            _token = _draw(source, action)
        }
        SignalConnection(DrawingArea source, void<int64, fp64, fp64> action) {
            _token = _click(source, action)
        }
        SignalConnection(DrawingArea source, void<int64, fp64, fp64, fp64, fp64> action) {
            _token = _drag(source, action)
        }
        SignalConnection(DrawingArea source, void<fp64, fp64, fp64, fp64> action) {
            _token = _scroll(source, action)
        }
        SignalConnection(ContextMenu source, void<fp64, fp64> action) {
            _token = _popup(source, action)
        }
        SignalConnection(Scrollbar source, void<fp64> action) {
            _token = _valueChanged(source, action)
        }
        SignalConnection(Scale source, void<fp64> action) {
            _token = _valueChanged(source, action)
        }
        SignalConnection(SpinButton source, void<fp64> action) {
            _token = _valueChanged(source, action)
        }
        SignalConnection(DropDown source, void<int64> action) {
            _token = _selected(source, action)
        }
        SignalConnection(TextView source, void<String> action) {
            _token = _changed(source, action)
        }
        bool disconnect() { return(_disconnect(_token))}
        bool connected() { return(_connected(_token))}
    }

    class Widget {
        private:
        int64 _id
        Widget _self()
        void _keepAlive() {}
        int64 _create(int64 kind, String text, int64 orientation, int64 spacing, void<> root)
        void _dispose(int64 token)
        bool _disposed(int64 token)
        void _visible(int64 token, bool value)
        bool _isVisible(int64 token)
        void _sensitive(int64 token, bool value)
        void _expand(int64 token, bool horizontal, bool value)
        void _widthRequest(int64 token, int64 width)
        void _cssClass(int64 token, String name, bool add)
        void _tooltip(int64 token, String text)
        void _focus(int64 token)
        void _focusOnClick(int64 token, bool enabled)
        void _canFocus(int64 token, bool enabled)
        void _textSet(int64 token, String text)
        String _textGet(int64 token)
        void _attach(int64 parent, int64 child)
        void _remove(int64 parent, int64 child)
        void _windowAction(int64 token, int64 action)
        void _windowSize(int64 token, int64 width, int64 height)
        int64 _windowWidth(int64 token)
        int64 _windowHeight(int64 token)
        void _windowTransientFor(int64 token, int64 parent)
        void _layout(int64 token, int64 orientation, int64 spacing)
        void _activeSet(int64 token, bool value)
        bool _activeGet(int64 token)
        protected:
        void _notebookAppend(int64 notebook, int64 child, String title)
        int64 _notebookCurrent(int64 notebook)
        void _notebookSetCurrent(int64 notebook, int64 page)
        int64 _notebookCount(int64 notebook)
        void _notebookTitle(int64 notebook, int64 page, String title)
        Widget(int64 kind, String text, int64 orientation, int64 spacing) {
            _id = _create(kind, text, orientation, spacing, _self()._keepAlive)
        }
        void _setText(String text) { _textSet(_id, text) }
        String _getText() { return(_textGet(_id))}
        void _attachChild(Widget child) { _attach(_id, child._id) }
        void _removeChild(Widget child) { _remove(_id, child._id) }
        void _presentWindow() { _windowAction(_id, 0) }
        void _closeWindow() { _windowAction(_id, 1) }
        void _sizeWindow(int64 width, int64 height) { _windowSize(_id, width, height) }
        int64 _defaultWidth() { return(_windowWidth(_id))}
        int64 _defaultHeight() { return(_windowHeight(_id))}
        void _setTransientFor(int64 parent) { _windowTransientFor(_id, parent) }
        void _boxLayout(int64 orientation, int64 spacing) { _layout(_id, orientation, spacing) }
        void _setActive(bool value) { _activeSet(_id, value) }
        bool _getActive() { return(_activeGet(_id))}
        void _grabFocus() { _focus(_id) }
        public:
        int64 _widgetToken() { return(_id)}
        void dispose() { _dispose(_id) }
        bool disposed() { return(_disposed(_id))}
        void setVisible(bool value) { _visible(_id, value) }
        bool visible() { return(_isVisible(_id)) }
        void setSensitive(bool value) { _sensitive(_id, value) }
        void setHExpand(bool value) { _expand(_id, true, value) }
        void setVExpand(bool value) { _expand(_id, false, value) }
        void setWidthRequest(int64 width) { _widthRequest(_id, width) }
        void addCssClass(String name) { _cssClass(_id, name, true) }
        void removeCssClass(String name) { _cssClass(_id, name, false) }
        void setTooltip(String text) { _tooltip(_id, text) }
        // Buttons default to focus-on-click off; use these for toolbar controls
        // that must not take focus from an editor on the first press.
        void setFocusOnClick(bool enabled) { _focusOnClick(_id, enabled) }
        void setCanFocus(bool enabled) { _canFocus(_id, enabled) }
    }

    class Window : Widget {
        private:
        Window _windowSelf()
        bool _bindShortcut(int64 token, String trigger, void<> action)
        bool _hasShortcut(int64 token, String trigger)
        void _clearWindowShortcuts(int64 token)
        bool _maximized(int64 token)
        void _maximize(int64 token, bool enabled)
        void _setMenubarAccel(int64 token, bool enabled)
        bool _menubarAccel(int64 token)
        public:
        Window(String title) { super Widget(1, title, 0, 0) }
        void setTitle(String title) { _setText(title) }
        String title() { return(_getText())}
        void setDefaultSize(int64 width, int64 height) { _sizeWindow(width, height) }
        int64 defaultWidth() { return(_defaultWidth())}
        int64 defaultHeight() { return(_defaultHeight())}
        bool maximized() { return(_maximized(_widgetToken()))}
        void setMaximized(bool enabled) { _maximize(_widgetToken(), enabled) }
        // GTK defaults to consuming F10 for the menubar; set false when F10 is
        // an application shortcut (bindShortcut("F10", ...) also clears it).
        void setMenubarAccel(bool enabled) { _setMenubarAccel(_widgetToken(), enabled) }
        bool menubarAccel() { return(_menubarAccel(_widgetToken()))}
        void setTransientFor(Window parent) {
            _setTransientFor(parent._widgetToken())
        }
        void setChild(Widget child) { _attachChild(child) }
        void remove(Widget child) { _removeChild(child) }
        void present() { _presentWindow() }
        void close() { _closeWindow() }
        // Binds a GTK accelerator such as "<Control>q" for the whole window.
        bool bindShortcut(String trigger, void<> action) {
            return(_bindShortcut(_widgetToken(), trigger, action))
        }
        bool hasShortcut(String trigger) { return(_hasShortcut(_widgetToken(), trigger))}
        // Same native helper as SourceView.clearShortcuts: drops every binding
        // installed through bindShortcut on this window.
        void clearShortcuts() { _clearWindowShortcuts(_widgetToken()) }
        SignalConnection onCloseRequest(bool<> action) {
            return(SignalConnection(_windowSelf(), action))
        }
        SignalConnection onFocusChanged(void<bool> action) {
            return(SignalConnection(_windowSelf(), action))
        }
    }

    class TransientWindow : Widget {
        private:
        TransientWindow _transientSelf()
        public:
        TransientWindow(String title) { super Widget(11, title, 0, 0) }
        void setTitle(String title) { _setText(title) }
        String title() { return(_getText())}
        void setDefaultSize(int64 width, int64 height) { _sizeWindow(width, height) }
        void setTransientFor(Window parent) {
            _setTransientFor(parent._widgetToken())
        }
        void setChild(Widget child) { _attachChild(child) }
        void remove(Widget child) { _removeChild(child) }
        void present() { _presentWindow() }
        void close() { _closeWindow() }
        SignalConnection onCloseRequest(bool<> action) {
            return(SignalConnection(_transientSelf(), action))
        }
    }

    class Box : Widget {
        public:
        enum { HORIZONTAL = 0, VERTICAL = 1 }
        Box(int64 orientation, int64 spacing) { super Widget(2, "", orientation, spacing) }
        void setLayout(int64 orientation, int64 spacing) { _boxLayout(orientation, spacing) }
        void append(Widget child) { _attachChild(child) }
        void remove(Widget child) { _removeChild(child) }
    }

    class Label : Widget {
        public:
        Label(String text) { super Widget(3, text, 0, 0) }
        void setText(String text) { _setText(text) }
        String text() { return(_getText())}
    }

    class Grid : Widget {
        private:
        void _attachAt(int64 token, int64 child, int64 column, int64 row, int64 width, int64 height)
        public:
        Grid(int64 spacing) { super Widget(14, "", 0, spacing) }
        void attach(Widget child, int64 column, int64 row, int64 width, int64 height) {
            _attachAt(_widgetToken(), child._widgetToken(), column, row, width, height)
        }
    }

    class ContextMenu : Widget {
        private:
        ContextMenu _menuSelf()
        void _bind(int64 token, int64 owner)
        int64 _addItem(int64 token, int64 menu, String label, void<> action)
        int64 _addCheck(int64 token, int64 menu, String label, bool initial, void<bool> action)
        int64 _addSubmenu(int64 token, int64 menu, String label)
        void _separator(int64 token, int64 menu)
        void _clearMenu(int64 token, int64 menu)
        void _popupAt(int64 token, fp64 x, fp64 y)
        void _enabled(int64 token, int64 item, bool value)
        void _checked(int64 token, int64 item, bool value)
        bool _isChecked(int64 token, int64 item)
        public:
        // Attaches a secondary-button PopoverMenu to owner (any Widget,
        // including DrawingArea). Right-click coords are delivered via onPopup
        // before the menu opens so the app can clear/rebuild items.
        ContextMenu(Widget owner) {
            super Widget(15, "", 0, 0)
            _bind(_widgetToken(), owner._widgetToken())
        }
        // Prefer addItem/addCheckItem so the menu looks like a native popup.
        // setChild still accepts a custom widget for callers that need one.
        void setChild(Widget child) { _attachChild(child) }
        // Appends a row to the root menu; returns an item token for enable/check.
        int64 addItem(String label, void<> action) {
            return(_addItem(_widgetToken(), 0, label, action))
        }
        // Appends a row to submenu index from addSubmenu.
        int64 addItem(int64 menu, String label, void<> action) {
            return(_addItem(_widgetToken(), menu, label, action))
        }
        int64 addCheckItem(String label, bool initial, void<bool> action) {
            return(_addCheck(_widgetToken(), 0, label, initial, action))
        }
        int64 addCheckItem(int64 menu, String label, bool initial, void<bool> action) {
            return(_addCheck(_widgetToken(), menu, label, initial, action))
        }
        // Starts a new section on the root menu (native divider).
        void addSeparator() { _separator(_widgetToken(), 0) }
        void addSeparator(int64 menu) { _separator(_widgetToken(), menu) }
        // Nested submenu under the root; returns a menu index for addItem(menu, ...).
        int64 addSubmenu(String label) { return(_addSubmenu(_widgetToken(), 0, label)) }
        int64 addSubmenu(int64 menu, String label) {
            return(_addSubmenu(_widgetToken(), menu, label))
        }
        // Removes all rows from the root menu so the app can rebuild on each popup.
        void clear() { _clearMenu(_widgetToken(), 0) }
        void clearMenu(int64 menu) { _clearMenu(_widgetToken(), menu) }
        void setItemEnabled(int64 item, bool enabled) { _enabled(_widgetToken(), item, enabled) }
        void setItemChecked(int64 item, bool checked) { _checked(_widgetToken(), item, checked) }
        bool itemChecked(int64 item) { return(_isChecked(_widgetToken(), item)) }
        // Fires just before the menu opens with owner-local click coordinates.
        // A later onPopup replaces the previous callback.
        SignalConnection onPopup(void<fp64, fp64> action) {
            return(SignalConnection(_menuSelf(), action))
        }
        // Programmatic popup at owner-local coordinates (after building items).
        void popupAt(fp64 x, fp64 y) { _popupAt(_widgetToken(), x, y) }
    }

    // Standalone scrollbar for client-driven pan/zoom extents. Prefer
    // ScrolledWindow around a sized DrawingArea when stock bars suffice;
    // use Scrollbar when zoom is a draw-time transform and content size
    // stays fixed (configure lower/upper/page from current extents).
    class Scrollbar : Widget {
        private:
        Scrollbar _barSelf()
        void _configure(int64 token, fp64 value, fp64 lower, fp64 upper, fp64 step, fp64 page,
            fp64 pageSize)
        void _setValue(int64 token, fp64 value)
        fp64 _getValue(int64 token)
        fp64 _getLower(int64 token)
        fp64 _getUpper(int64 token)
        fp64 _getPageSize(int64 token)
        public:
        enum { HORIZONTAL = 0, VERTICAL = 1 }
        // Creates a GtkScrollbar; orientation matches Box/Paned (0/1).
        Scrollbar(int64 orientation) { super Widget(17, "", orientation, 0) }
        // Sets adjustment range and page size in one call (GTK clamps value).
        void configure(fp64 value, fp64 lower, fp64 upper, fp64 step, fp64 page, fp64 pageSize) {
            _configure(_widgetToken(), value, lower, upper, step, page, pageSize)
        }
        void setValue(fp64 value) { _setValue(_widgetToken(), value) }
        fp64 value() { return(_getValue(_widgetToken())) }
        fp64 lower() { return(_getLower(_widgetToken())) }
        fp64 upper() { return(_getUpper(_widgetToken())) }
        fp64 pageSize() { return(_getPageSize(_widgetToken())) }
        // Invoked when the user (or setValue) moves the thumb; arg is the new value.
        SignalConnection onValueChanged(void<fp64> action) {
            return(SignalConnection(_barSelf(), action))
        }
    }

    // Continuous or stepped numeric slider (GtkScale). Prefer Scale for
    // settings knobs; use Scrollbar for pan/zoom view extents.
    class Scale : Widget {
        private:
        Scale _scaleSelf()
        void _configure(int64 token, fp64 value, fp64 lower, fp64 upper, fp64 step)
        void _setValue(int64 token, fp64 value)
        fp64 _getValue(int64 token)
        fp64 _getLower(int64 token)
        fp64 _getUpper(int64 token)
        fp64 _getStep(int64 token)
        public:
        enum { HORIZONTAL = 0, VERTICAL = 1 }
        // Creates a GtkScale; orientation matches Box/Paned/Scrollbar (0/1).
        // Default range is 0..1 with step 0.1 until configure() is called.
        Scale(int64 orientation) { super Widget(18, "", orientation, 0) }
        // Sets value, inclusive lower/upper bounds, and step increment.
        // Page increment is step*10 (GTK Scale with-range convention).
        void configure(fp64 value, fp64 lower, fp64 upper, fp64 step) {
            _configure(_widgetToken(), value, lower, upper, step)
        }
        void setValue(fp64 value) { _setValue(_widgetToken(), value) }
        fp64 value() { return(_getValue(_widgetToken())) }
        fp64 lower() { return(_getLower(_widgetToken())) }
        fp64 upper() { return(_getUpper(_widgetToken())) }
        fp64 step() { return(_getStep(_widgetToken())) }
        // Invoked when the user (or setValue) moves the slider; arg is the new value.
        SignalConnection onValueChanged(void<fp64> action) {
            return(SignalConnection(_scaleSelf(), action))
        }
    }

    // Determinate or pulsing progress indicator (GtkProgressBar). Fraction is
    // 0..1; optional overlay text when showText is true; pulse() for unknown ETA.
    class ProgressBar : Widget {
        private:
        void _setFraction(int64 token, fp64 fraction)
        fp64 _getFraction(int64 token)
        void _setText(int64 token, String text)
        String _getText(int64 token)
        void _setShowText(int64 token, bool show)
        bool _getShowText(int64 token)
        void _pulse(int64 token)
        void _setPulseStep(int64 token, fp64 step)
        fp64 _getPulseStep(int64 token)
        public:
        enum { HORIZONTAL = 0, VERTICAL = 1 }
        // Creates a GtkProgressBar; orientation matches Box/Paned/Scale (0/1).
        // Defaults: fraction 0, showText false, empty text, pulseStep 0.1.
        ProgressBar(int64 orientation) { super Widget(19, "", orientation, 0) }
        // Sets filled fraction in [0.0, 1.0]; out-of-range values abort.
        void setFraction(fp64 fraction) { _setFraction(_widgetToken(), fraction) }
        fp64 fraction() { return(_getFraction(_widgetToken())) }
        // Overlay label when showText is true; empty string clears custom text
        // so GTK may show a percentage when showText remains enabled.
        void setText(String text) { _setText(_widgetToken(), text) }
        String text() { return(_getText(_widgetToken())) }
        void setShowText(bool show) { _setShowText(_widgetToken(), show) }
        bool showText() { return(_getShowText(_widgetToken())) }
        // Advances an indeterminate pulse animation by pulseStep.
        void pulse() { _pulse(_widgetToken()) }
        // Fraction advanced per pulse(); must be in (0.0, 1.0].
        void setPulseStep(fp64 step) { _setPulseStep(_widgetToken(), step) }
        fp64 pulseStep() { return(_getPulseStep(_widgetToken())) }
    }

    // Integer or stepped numeric entry with +/- buttons (GtkSpinButton). Prefer
    // SpinButton for discrete counts and bounded integers; use Scale for
    // continuous sliders and Scrollbar for pan/zoom extents.
    class SpinButton : Widget {
        private:
        SpinButton _spinSelf()
        void _configure(int64 token, fp64 value, fp64 lower, fp64 upper, fp64 step)
        void _setValue(int64 token, fp64 value)
        fp64 _getValue(int64 token)
        fp64 _getLower(int64 token)
        fp64 _getUpper(int64 token)
        fp64 _getStep(int64 token)
        public:
        // Creates a GtkSpinButton. Default range is 0..100 with step 1 until
        // configure() is called. Digits track the step size (same heuristic as Scale).
        SpinButton() { super Widget(20, "", 0, 0) }
        // Sets value, inclusive lower/upper bounds, and step increment.
        // Page increment is step*10 (matches Scale / gtk_spin_button_new_with_range).
        void configure(fp64 value, fp64 lower, fp64 upper, fp64 step) {
            _configure(_widgetToken(), value, lower, upper, step)
        }
        // Writes the spin value; GTK clamps to the configured range.
        void setValue(fp64 value) { _setValue(_widgetToken(), value) }
        // Current spin value (may be fractional when step < 1).
        fp64 value() { return(_getValue(_widgetToken())) }
        // Inclusive lower bound from the last configure().
        fp64 lower() { return(_getLower(_widgetToken())) }
        // Inclusive upper bound from the last configure().
        fp64 upper() { return(_getUpper(_widgetToken())) }
        // Step increment from the last configure().
        fp64 step() { return(_getStep(_widgetToken())) }
        // Invoked when the user (or setValue) changes the value; arg is the new value.
        SignalConnection onValueChanged(void<fp64> action) {
            return(SignalConnection(_spinSelf(), action))
        }
    }

    // Selectable string list (GtkDropDown) for enums and id pickers. Build the
    // model with clear()/append() or setChoices(list); read selected()/selectedText().
    class DropDown : Widget {
        private:
        DropDown _dropSelf()
        void _clear(int64 token)
        void _append(int64 token, String label)
        void _setSelected(int64 token, int64 index)
        int64 _getSelected(int64 token)
        String _getSelectedText(int64 token)
        int64 _getSize(int64 token)
        String _getItem(int64 token, int64 index)
        public:
        // Creates an empty GtkDropDown backed by a GtkStringList model.
        DropDown() { super Widget(21, "", 0, 0) }
        // Removes every choice; selected() becomes -1 until append/setSelected.
        void clear() { _clear(_widgetToken()) }
        // Appends one visible choice string at the end of the model.
        void append(String label) { _append(_widgetToken(), label) }
        // Replaces all choices with the given list of String labels (may be empty).
        // Keeps the prior selectedText when it still appears in the new list;
        // otherwise selects index 0 when nonempty, or -1 when empty.
        void setChoices(list labels) {
            String prior = selectedText()
            clear()
            int64 i = 0
            while (i < labels.length) {
                append(labels[i])
                i = i + 1
            }
            if (labels.length < 1) {
                return()
            }
            if (prior.length > 0) {
                int64 found = 0
                while (found < labels.length) {
                    String item = labels[found]
                    if (item.equals(prior)) {
                        setSelected(found)
                        return()
                    }
                    found = found + 1
                }
            }
            setSelected(0)
        }
        // Selects choice at index (0-based). Pass -1 to clear the selection.
        // Out-of-range nonnegative indices abort.
        void setSelected(int64 index) { _setSelected(_widgetToken(), index) }
        // Selected 0-based index, or -1 when nothing is selected / model empty.
        int64 selected() { return(_getSelected(_widgetToken())) }
        // Text of the selected choice, or "" when nothing is selected.
        String selectedText() { return(_getSelectedText(_widgetToken())) }
        // Number of choices currently in the model.
        int64 size() { return(_getSize(_widgetToken())) }
        // Choice text at index; out-of-range indices abort.
        String item(int64 index) { return(_getItem(_widgetToken(), index)) }
        // Invoked when the selection changes (user or setSelected); arg is the
        // new selected index, or -1 when cleared.
        SignalConnection onSelected(void<int64> action) {
            return(SignalConnection(_dropSelf(), action))
        }
    }

    // Labeled decorative frame around a single child (GtkFrame). Use for grouped
    // dialog sections; empty label hides the frame title.
    class Frame : Widget {
        private:
        void _setLabel(int64 token, String label)
        String _getLabel(int64 token)
        public:
        // Creates a GtkFrame; label may be empty (no title).
        Frame(String label) { super Widget(22, label, 0, 0) }
        // Sets the frame title; empty string clears it.
        void setLabel(String label) { _setLabel(_widgetToken(), label) }
        // Current frame title, or "" when unset.
        String label() { return(_getLabel(_widgetToken())) }
        // Sets the single child widget (replacing any previous child).
        void setChild(Widget child) { _attachChild(child) }
        // Detaches child if it is the current frame child.
        void remove(Widget child) { _removeChild(child) }
    }

    // Collapsible section with a clickable header (GtkExpander). Child is shown
    // only while expanded.
    class Expander : Widget {
        private:
        void _setLabel(int64 token, String label)
        String _getLabel(int64 token)
        void _setExpanded(int64 token, bool expanded)
        bool _getExpanded(int64 token)
        public:
        // Creates a GtkExpander; starts collapsed. Label is the header text.
        Expander(String label) { super Widget(23, label, 0, 0) }
        // Sets the expander header label.
        void setLabel(String label) { _setLabel(_widgetToken(), label) }
        // Current header label.
        String label() { return(_getLabel(_widgetToken())) }
        // Expands or collapses the child area.
        void setExpanded(bool expanded) { _setExpanded(_widgetToken(), expanded) }
        // True when the child is visible.
        bool expanded() { return(_getExpanded(_widgetToken())) }
        // Sets the single collapsible child widget.
        void setChild(Widget child) { _attachChild(child) }
        // Detaches child if it is the current expander child.
        void remove(Widget child) { _removeChild(child) }
    }

    // Horizontal or vertical dividing line (GtkSeparator) for dialog layout.
    class Separator : Widget {
        public:
        enum { HORIZONTAL = 0, VERTICAL = 1 }
        // Creates a GtkSeparator; orientation matches Box/Paned/Scale (0/1).
        Separator(int64 orientation) { super Widget(24, "", orientation, 0) }
    }

    // Plain multiline text editor (GtkTextView). Prefer TextView for compose /
    // digest panes; use the sourceview package for syntax-aware editors.
    class TextView : Widget {
        private:
        TextView _textSelf()
        void _setText(int64 token, String text)
        String _getText(int64 token)
        void _editable(int64 token, bool editable)
        bool _getEditable(int64 token)
        void _wrap(int64 token, bool wrap)
        bool _getWrap(int64 token)
        public:
        // Creates an empty editable GtkTextView with word wrap enabled.
        TextView() { super Widget(25, "", 0, 0) }
        // Replaces the entire buffer contents.
        void setText(String text) { _setText(_widgetToken(), text) }
        // Full buffer text (may contain newlines).
        String text() { return(_getText(_widgetToken())) }
        // Enables or disables user editing; programmatic setText still works.
        void setEditable(bool editable) { _editable(_widgetToken(), editable) }
        // True when the user can type into the view.
        bool editable() { return(_getEditable(_widgetToken())) }
        // Word-wraps long lines when true; otherwise scrolls horizontally.
        void setWrap(bool wrap) { _wrap(_widgetToken(), wrap) }
        // True when word wrap is enabled.
        bool wrap() { return(_getWrap(_widgetToken())) }
        // Invoked when buffer text changes; arg is the full buffer contents.
        SignalConnection onChanged(void<String> action) {
            return(SignalConnection(_textSelf(), action))
        }
    }

    class Button : Widget {
        private:
        Button _buttonSelf()
        void _icon(int64 token, String name)
        public:
        Button(String label) { super Widget(4, label, 0, 0) }
        void setLabel(String label) { _setText(label) }
        String label() { return(_getText())}
        void setIconName(String name) { _icon(_widgetToken(), name) }
        SignalConnection onClicked(void<> action) {
            return(SignalConnection(_buttonSelf(), action))
        }
    }

    class Entry : Widget {
        private:
        Entry _entrySelf()
        void _editable(int64 token, bool editable)
        public:
        Entry(String text) { super Widget(5, text, 0, 0) }
        void setText(String text) { _setText(text) }
        String text() { return(_getText())}
        SignalConnection onChanged(void<String> action) {
            return(SignalConnection(_entrySelf(), action))
        }
        void focus() { _grabFocus() }
        void setEditable(bool editable) { _editable(_widgetToken(), editable) }
    }

    class MenuBar : Widget {
        private:
        int64 _addMenu(int64 token, String label)
        int64 _addItem(int64 token, int64 menu, String label, void<> action)
        void _enabled(int64 token, int64 item, bool value)
        void _activate(int64 token, int64 item)
        void _separator(int64 token, int64 menu)
        int64 _addCheck(int64 token, int64 menu, String label, bool initial, void<bool> action)
        int64 _addSubmenu(int64 token, int64 menu, String label)
        void _clearMenu(int64 token, int64 menu)
        void _checked(int64 token, int64 item, bool value)
        bool _isChecked(int64 token, int64 item)
        public:
        MenuBar() { super Widget(10, "", 0, 0) }
        int64 addMenu(String label) { return(_addMenu(_widgetToken(), label))}
        int64 addItem(int64 menu, String label, void<> action) {
            return(_addItem(_widgetToken(), menu, label, action))
        }
        // Draws a divider before the next item added to menu.
        void addSeparator(int64 menu) { _separator(_widgetToken(), menu) }
        int64 addCheckItem(int64 menu, String label, bool initial, void<bool> action) {
            return(_addCheck(_widgetToken(), menu, label, initial, action))
        }
        int64 addSubmenu(int64 menu, String label) {
            return(_addSubmenu(_widgetToken(), menu, label))
        }
        void clearMenu(int64 menu) { _clearMenu(_widgetToken(), menu) }
        void setItemEnabled(int64 item, bool enabled) { _enabled(_widgetToken(), item, enabled) }
        void activateItem(int64 item) { _activate(_widgetToken(), item) }
        void setItemChecked(int64 item, bool checked) { _checked(_widgetToken(), item, checked) }
        bool itemChecked(int64 item) { return(_isChecked(_widgetToken(), item)) }
    }

    class FileSelection {
        private:
        list _paths
        void<list> _result
        public:
        FileSelection(void<list> result) {
            _paths = []
            _result = result
        }
        void add(String path) {
            if (!path.equals("")) {
                _paths.append(path)
                return
            }
            list paths = _paths
            _paths = []
            _result(paths)
        }
    }

    class FileDialog {
        private:
        int64 _token
        FileSelection _selection
        int64 _create(int64 parent, bool save, String initialPath, void<String> result)
        int64 _createMultiple(int64 parent, String initialPath, void<String> path)
        int64 _createFolder(int64 parent, String initialPath, void<String> result)
        void _cancel(int64 token)
        bool _pending(int64 token)
        public:
        FileDialog(Window parent, bool save, String initialPath, void<String> result) {
            _token = _create(parent._widgetToken(), save, initialPath, result)
        }
        FileDialog(Window parent, String initialPath, void<list> results) {
            _selection = FileSelection(results)
            _token = _createMultiple(parent._widgetToken(), initialPath, _selection.add)
        }
        FileDialog(Window parent, String initialPath, void<String> folder) {
            _token = _createFolder(parent._widgetToken(), initialPath, folder)
        }
        void cancel() { _cancel(_token) }
        bool pending() { return(_pending(_token))}
    }

    class AlertDialog {
        private:
        void _show(int64 parent, String message, String detail)
        public:
        // Shows a modal error/information alert over parent; it closes itself.
        void show(Window parent, String message, String detail) {
            _show(parent._widgetToken(), message, detail)
        }
    }

    class CheckButton : Widget {
        private:
        CheckButton _checkSelf()
        public:
        CheckButton(String label) { super Widget(6, label, 0, 0) }
        void setLabel(String label) { _setText(label) }
        String label() { return(_getText())}
        void setActive(bool value) { _setActive(value) }
        bool active() { return(_getActive())}
        SignalConnection onToggled(void<bool> action) {
            return(SignalConnection(_checkSelf(), action))
        }
    }

    class ScrolledWindow : Widget {
        // Matches GtkPolicyType: always / automatic / never / external.
        enum { POLICY_ALWAYS = 0, POLICY_AUTOMATIC = 1, POLICY_NEVER = 2, POLICY_EXTERNAL = 3 }
        public:
        ScrolledWindow() { super Widget(7, "", 0, 0) }
        void setChild(Widget child) { _attachChild(child) }
        void remove(Widget child) { _removeChild(child) }
        void setPolicy(int64 horizontal, int64 vertical) {
            _policy(_widgetToken(), horizontal, vertical)
        }
        void setOverlayScrolling(bool enabled) {
            _overlay(_widgetToken(), enabled)
        }
        void _policy(int64 token, int64 horizontal, int64 vertical)
        void _overlay(int64 token, bool enabled)
    }
    void ScrolledWindow._policy(int64 token, int64 horizontal, int64 vertical)
        from "cwhip_gtk_scrolled_window_set_policy"
    void ScrolledWindow._overlay(int64 token, bool enabled)
        from "cwhip_gtk_scrolled_window_set_overlay_scrolling"

    class Notebook : Widget {
        private:
        Notebook _notebookSelf()
        void _closable(int64 token, int64 child, String title, void<> close)
        void _bordered(int64 token)
        void _scrollable(int64 token, bool enabled)
        public:
        Notebook() { super Widget(9, "", 0, 0) }
        void appendPage(Widget child, String title) {
            _notebookAppend(_widgetToken(), child._widgetToken(), title)
        }
        void appendClosablePage(Widget child, String title, void<> close) {
            _closable(_widgetToken(), child._widgetToken(), title, close)
        }
        // Draws a border around every tab label, as closable pages already do.
        void setBorderedTabs() { _bordered(_widgetToken()) }
        void setScrollable(bool enabled) { _scrollable(_widgetToken(), enabled) }
        int64 currentPage() { return(_notebookCurrent(_widgetToken()))}
        void setCurrentPage(int64 page) { _notebookSetCurrent(_widgetToken(), page) }
        int64 pageCount() { return(_notebookCount(_widgetToken()))}
        void setPageTitle(int64 page, String title) {
            _notebookTitle(_widgetToken(), page, title)
        }
        void remove(Widget child) { _removeChild(child) }
        SignalConnection onPageChanged(void<> action) {
            return(SignalConnection(_notebookSelf(), action))
        }
    }

    class Paned : Widget {
        private:
        void _position(int64 token, int64 position)
        int64 _getPosition(int64 token)
        public:
        enum { HORIZONTAL = 0, VERTICAL = 1 }
        // Default remains a horizontal split for existing call sites.
        Paned() { super Widget(12, "", HORIZONTAL, 0) }
        Paned(int64 orientation) { super Widget(12, "", orientation, 0) }
        void append(Widget child) { _attachChild(child) }
        void setPosition(int64 position) { _position(_widgetToken(), position) }
        int64 position() { return(_getPosition(_widgetToken()))}
    }

    // Custom paint surface embeddable as a normal child of Box, Paned,
    // Notebook, ScrolledWindow, Grid, or Window. Paint helpers are valid only
    // inside the onDraw callback. For view chrome: wrap with ScrolledWindow
    // after setContentSize, and/or drive Scrollbar widgets from pan/zoom
    // extents; attach ContextMenu(area) and rebuild items in onPopup.
    class DrawingArea : Widget {
        private:
        DrawingArea _drawSelf()
        void _queueDraw(int64 token)
        void _contentSize(int64 token, int64 width, int64 height)
        void _color(int64 token, fp64 r, fp64 g, fp64 b, fp64 a)
        void _lineWidth(int64 token, fp64 width)
        void _fillRect(int64 token, fp64 x, fp64 y, fp64 width, fp64 height)
        void _strokeRect(int64 token, fp64 x, fp64 y, fp64 width, fp64 height)
        void _fillCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)
        void _strokeCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)
        void _strokeLine(int64 token, fp64 x1, fp64 y1, fp64 x2, fp64 y2)
        public:
        // Mouse button numbers match GDK (1 primary, 2 middle, 3 secondary).
        enum { BUTTON_PRIMARY = 1, BUTTON_MIDDLE = 2, BUTTON_SECONDARY = 3 }
        // onDrag phase values: begin at the press point, then update/end offsets.
        enum { DRAG_BEGIN = 0, DRAG_UPDATE = 1, DRAG_END = 2 }
        DrawingArea() { super Widget(16, "", 0, 0) }
        // Marks the area dirty so GTK schedules another onDraw.
        void queueDraw() { _queueDraw(_widgetToken()) }
        // Sets GtkDrawingArea content width/height used for measuring
        // (useful inside ScrolledWindow or when a fixed canvas size is wanted).
        void setContentSize(int64 width, int64 height) {
            _contentSize(_widgetToken(), width, height)
        }
        // Installs the paint callback; width/height are the current allocation.
        // A later onDraw replaces the previous draw func.
        SignalConnection onDraw(void<int64, int64> action) {
            return(SignalConnection(_drawSelf(), action))
        }
        // Click with widget-local coordinates. Fires on release of any button
        // (button is BUTTON_PRIMARY / MIDDLE / SECONDARY). A primary-button
        // drag that moves past GTK's drag threshold typically suppresses the
        // click so pick and pan can share the left button.
        SignalConnection onClick(void<int64, fp64, fp64> action) {
            return(SignalConnection(_drawSelf(), action))
        }
        // Primary-button drag for pan. Callback args are
        // (phase, start_x, start_y, offset_x, offset_y) with phase DRAG_*.
        SignalConnection onDrag(void<int64, fp64, fp64, fp64, fp64> action) {
            return(SignalConnection(_drawSelf(), action))
        }
        // Scroll-wheel / trackpad scroll for zoom. Args are (x, y, dx, dy) in
        // widget coordinates; x/y are the pointer focus when known.
        SignalConnection onScroll(void<fp64, fp64, fp64, fp64> action) {
            return(SignalConnection(_drawSelf(), action))
        }
        // Source color for subsequent fill/stroke calls (components 0..1).
        void setColor(fp64 r, fp64 g, fp64 b, fp64 a) {
            _color(_widgetToken(), r, g, b, a)
        }
        void setLineWidth(fp64 width) { _lineWidth(_widgetToken(), width) }
        void fillRect(fp64 x, fp64 y, fp64 width, fp64 height) {
            _fillRect(_widgetToken(), x, y, width, height)
        }
        void strokeRect(fp64 x, fp64 y, fp64 width, fp64 height) {
            _strokeRect(_widgetToken(), x, y, width, height)
        }
        void fillCircle(fp64 cx, fp64 cy, fp64 radius) {
            _fillCircle(_widgetToken(), cx, cy, radius)
        }
        void strokeCircle(fp64 cx, fp64 cy, fp64 radius) {
            _strokeCircle(_widgetToken(), cx, cy, radius)
        }
        void strokeLine(fp64 x1, fp64 y1, fp64 x2, fp64 y2) {
            _strokeLine(_widgetToken(), x1, y1, x2, y2)
        }
    }

    class Tree : Widget {
        private:
        void _singleClick(int64 token, bool enabled)
        void _setup(int64 token, void<int64> request, void<int64> activate)
        void _add(int64 token, int64 parent, int64 id, String label, String icon, bool expandable, String value, int64 data)
        void _clear(int64 token, int64 parent)
        void _expandRow(int64 token, int64 id, bool expanded)
        bool _isExpanded(int64 token, int64 id)
        String _value(int64 token, int64 id)
        int64 _data(int64 token, int64 id)
        int64 _find(int64 token, String value)
        int64 _count(int64 token, int64 parent)
        public:
        Tree(void<int64> request, void<int64> activate) {
            super Widget(13, "", 0, 0)
            _setup(_widgetToken(), request, activate)
        }
        void setSingleClickActivate(bool enabled) { _singleClick(_widgetToken(), enabled) }
        void add(int64 parent, int64 id, String label, String icon, bool expandable, String value, int64 data) {
            _add(_widgetToken(), parent, id, label, icon, expandable, value, data)
        }
        void clear(int64 parent) { _clear(_widgetToken(), parent) }
        void setExpanded(int64 id, bool expanded) { _expandRow(_widgetToken(), id, expanded) }
        bool expanded(int64 id) { return(_isExpanded(_widgetToken(), id))}
        String value(int64 id) { return(_value(_widgetToken(), id))}
        int64 data(int64 id) { return(_data(_widgetToken(), id))}
        int64 findValue(String value) { return(_find(_widgetToken(), value))}
        int64 childCount(int64 parent) { return(_count(_widgetToken(), parent))}
    }

    class DirectoryScan {
        private:
        int64 _token
        int64 _start(int64 owner, String path, bool hidden, void<int64, String> result)
        int64 _startFiltered(int64 owner, String path, bool hidden, String root, String excludes,
            void<int64, String> result)
        void _cancel(int64 token)
        void _append(int64 token, int64 tree, int64 parent, int64 firstId, int64 count, String icons)
        public:
        DirectoryScan(Tree owner, String path, bool hidden, void<int64, String> result) {
            _token = _start(owner._widgetToken(), path, hidden, result)
        }
        DirectoryScan(Tree owner, String path, bool hidden, String root, String excludes,
            void<int64, String> result) {
            _token = _startFiltered(owner._widgetToken(), path, hidden, root, excludes, result)
        }
        void cancel() { _cancel(_token) }
        void append(Tree owner, int64 parent, int64 firstId, int64 count, String icons) {
            _append(_token, owner._widgetToken(), parent, firstId, count, icons)
        }
    }

    class SourceViewWidget : Widget {
        public:
        SourceViewWidget() { super Widget(8, "", 0, 0) }
        int64 nativeToken() { return(_widgetToken())}
    }

    void Application._create(String id) from "cwhip_gtk_application_create"
    Application Application._self() from "cwhip_gtk_self"
    Widget Widget._self() from "cwhip_gtk_self"
    Window Window._windowSelf() from "cwhip_gtk_self"
    TransientWindow TransientWindow._transientSelf() from "cwhip_gtk_self"
    Button Button._buttonSelf() from "cwhip_gtk_self"
    Entry Entry._entrySelf() from "cwhip_gtk_self"
    CheckButton CheckButton._checkSelf() from "cwhip_gtk_self"
    Notebook Notebook._notebookSelf() from "cwhip_gtk_self"
    DrawingArea DrawingArea._drawSelf() from "cwhip_gtk_self"
    ContextMenu ContextMenu._menuSelf() from "cwhip_gtk_self"
    Scrollbar Scrollbar._barSelf() from "cwhip_gtk_self"
    Scale Scale._scaleSelf() from "cwhip_gtk_self"
    SpinButton SpinButton._spinSelf() from "cwhip_gtk_self"
    DropDown DropDown._dropSelf() from "cwhip_gtk_self"
    TextView TextView._textSelf() from "cwhip_gtk_self"
    void Application.initialize() from "cwhip_gtk_initialize"
    String Application.id() from "cwhip_gtk_application_id"
    void Application.run() from "cwhip_gtk_run"
    void Application.quit() from "cwhip_gtk_quit"
    void Application.shutdown() from "cwhip_gtk_shutdown"
    int64 Application.post(void<> action) from "cwhip_gtk_post"
    int64 Application.schedule(int64 milliseconds, void<> action) from "cwhip_gtk_schedule"
    bool Application.cancel(int64 token) from "cwhip_gtk_cancel"
    int64 SignalConnection._activate(Application source, void<> action)
        from "cwhip_gtk_activation_signal"
    int64 SignalConnection._click(Button source, void<> action) from "cwhip_gtk_button_signal"
    int64 SignalConnection._changed(Entry source, void<String> action) from "cwhip_gtk_entry_signal"
    int64 SignalConnection._close(Window source, bool<> action) from "cwhip_gtk_window_signal"
    int64 SignalConnection._close(TransientWindow source, bool<> action)
        from "cwhip_gtk_window_signal"
    int64 SignalConnection._toggled(CheckButton source, void<bool> action) from "cwhip_gtk_checkbox_signal"
    int64 SignalConnection._pageChanged(Notebook source, void<> action)
        from "cwhip_gtk_notebook_signal"
    int64 SignalConnection._focusChanged(Window source, void<bool> action)
        from "cwhip_gtk_window_focus_signal"
    int64 SignalConnection._draw(DrawingArea source, void<int64, int64> action)
        from "cwhip_gtk_drawing_area_signal"
    int64 SignalConnection._click(DrawingArea source, void<int64, fp64, fp64> action)
        from "cwhip_gtk_drawing_area_click_signal"
    int64 SignalConnection._drag(DrawingArea source, void<int64, fp64, fp64, fp64, fp64> action)
        from "cwhip_gtk_drawing_area_drag_signal"
    int64 SignalConnection._scroll(DrawingArea source, void<fp64, fp64, fp64, fp64> action)
        from "cwhip_gtk_drawing_area_scroll_signal"
    int64 SignalConnection._popup(ContextMenu source, void<fp64, fp64> action)
        from "cwhip_gtk_context_menu_popup_signal"
    int64 SignalConnection._valueChanged(Scrollbar source, void<fp64> action)
        from "cwhip_gtk_scrollbar_signal"
    int64 SignalConnection._valueChanged(Scale source, void<fp64> action)
        from "cwhip_gtk_scale_signal"
    int64 SignalConnection._valueChanged(SpinButton source, void<fp64> action)
        from "cwhip_gtk_spin_button_signal"
    int64 SignalConnection._selected(DropDown source, void<int64> action)
        from "cwhip_gtk_drop_down_signal"
    int64 SignalConnection._changed(TextView source, void<String> action)
        from "cwhip_gtk_text_view_signal"
    void DrawingArea._queueDraw(int64 token) from "cwhip_gtk_drawing_area_queue_draw"
    void DrawingArea._contentSize(int64 token, int64 width, int64 height)
        from "cwhip_gtk_drawing_area_set_content_size"
    void DrawingArea._color(int64 token, fp64 r, fp64 g, fp64 b, fp64 a)
        from "cwhip_gtk_drawing_area_set_color"
    void DrawingArea._lineWidth(int64 token, fp64 width)
        from "cwhip_gtk_drawing_area_set_line_width"
    void DrawingArea._fillRect(int64 token, fp64 x, fp64 y, fp64 width, fp64 height)
        from "cwhip_gtk_drawing_area_fill_rect"
    void DrawingArea._strokeRect(int64 token, fp64 x, fp64 y, fp64 width, fp64 height)
        from "cwhip_gtk_drawing_area_stroke_rect"
    void DrawingArea._fillCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)
        from "cwhip_gtk_drawing_area_fill_circle"
    void DrawingArea._strokeCircle(int64 token, fp64 cx, fp64 cy, fp64 radius)
        from "cwhip_gtk_drawing_area_stroke_circle"
    void DrawingArea._strokeLine(int64 token, fp64 x1, fp64 y1, fp64 x2, fp64 y2)
        from "cwhip_gtk_drawing_area_stroke_line"
    void Grid._attachAt(int64 token, int64 child, int64 column, int64 row, int64 width, int64 height)
        from "cwhip_gtk_grid_attach"
    void ContextMenu._bind(int64 token, int64 owner) from "cwhip_gtk_context_menu_bind"
    int64 ContextMenu._addItem(int64 token, int64 menu, String label, void<> action)
        from "cwhip_gtk_menu_item_add"
    int64 ContextMenu._addCheck(int64 token, int64 menu, String label, bool initial, void<bool> action)
        from "cwhip_gtk_menu_check_add"
    int64 ContextMenu._addSubmenu(int64 token, int64 menu, String label)
        from "cwhip_gtk_menu_submenu_add"
    void ContextMenu._separator(int64 token, int64 menu) from "cwhip_gtk_menu_separator_add"
    void ContextMenu._clearMenu(int64 token, int64 menu) from "cwhip_gtk_menu_clear"
    void ContextMenu._popupAt(int64 token, fp64 x, fp64 y) from "cwhip_gtk_context_menu_popup_at"
    void ContextMenu._enabled(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_enabled"
    void ContextMenu._checked(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_set_checked"
    bool ContextMenu._isChecked(int64 token, int64 item) from "cwhip_gtk_menu_item_checked"
    void Scrollbar._configure(int64 token, fp64 value, fp64 lower, fp64 upper, fp64 step, fp64 page,
        fp64 pageSize) from "cwhip_gtk_scrollbar_configure"
    void Scrollbar._setValue(int64 token, fp64 value) from "cwhip_gtk_scrollbar_set_value"
    fp64 Scrollbar._getValue(int64 token) from "cwhip_gtk_scrollbar_get_value"
    fp64 Scrollbar._getLower(int64 token) from "cwhip_gtk_scrollbar_get_lower"
    fp64 Scrollbar._getUpper(int64 token) from "cwhip_gtk_scrollbar_get_upper"
    fp64 Scrollbar._getPageSize(int64 token) from "cwhip_gtk_scrollbar_get_page_size"
    void Scale._configure(int64 token, fp64 value, fp64 lower, fp64 upper, fp64 step)
        from "cwhip_gtk_scale_configure"
    void Scale._setValue(int64 token, fp64 value) from "cwhip_gtk_scale_set_value"
    fp64 Scale._getValue(int64 token) from "cwhip_gtk_scale_get_value"
    fp64 Scale._getLower(int64 token) from "cwhip_gtk_scale_get_lower"
    fp64 Scale._getUpper(int64 token) from "cwhip_gtk_scale_get_upper"
    fp64 Scale._getStep(int64 token) from "cwhip_gtk_scale_get_step"
    void ProgressBar._setFraction(int64 token, fp64 fraction)
        from "cwhip_gtk_progress_bar_set_fraction"
    fp64 ProgressBar._getFraction(int64 token) from "cwhip_gtk_progress_bar_get_fraction"
    void ProgressBar._setText(int64 token, String text) from "cwhip_gtk_progress_bar_set_text"
    String ProgressBar._getText(int64 token) from "cwhip_gtk_progress_bar_get_text"
    void ProgressBar._setShowText(int64 token, bool show)
        from "cwhip_gtk_progress_bar_set_show_text"
    bool ProgressBar._getShowText(int64 token) from "cwhip_gtk_progress_bar_get_show_text"
    void ProgressBar._pulse(int64 token) from "cwhip_gtk_progress_bar_pulse"
    void ProgressBar._setPulseStep(int64 token, fp64 step)
        from "cwhip_gtk_progress_bar_set_pulse_step"
    fp64 ProgressBar._getPulseStep(int64 token) from "cwhip_gtk_progress_bar_get_pulse_step"
    void SpinButton._configure(int64 token, fp64 value, fp64 lower, fp64 upper, fp64 step)
        from "cwhip_gtk_spin_button_configure"
    void SpinButton._setValue(int64 token, fp64 value) from "cwhip_gtk_spin_button_set_value"
    fp64 SpinButton._getValue(int64 token) from "cwhip_gtk_spin_button_get_value"
    fp64 SpinButton._getLower(int64 token) from "cwhip_gtk_spin_button_get_lower"
    fp64 SpinButton._getUpper(int64 token) from "cwhip_gtk_spin_button_get_upper"
    fp64 SpinButton._getStep(int64 token) from "cwhip_gtk_spin_button_get_step"
    void DropDown._clear(int64 token) from "cwhip_gtk_drop_down_clear"
    void DropDown._append(int64 token, String label) from "cwhip_gtk_drop_down_append"
    void DropDown._setSelected(int64 token, int64 index) from "cwhip_gtk_drop_down_set_selected"
    int64 DropDown._getSelected(int64 token) from "cwhip_gtk_drop_down_get_selected"
    String DropDown._getSelectedText(int64 token) from "cwhip_gtk_drop_down_get_selected_text"
    int64 DropDown._getSize(int64 token) from "cwhip_gtk_drop_down_get_size"
    String DropDown._getItem(int64 token, int64 index) from "cwhip_gtk_drop_down_get_item"
    void Frame._setLabel(int64 token, String label) from "cwhip_gtk_frame_set_label"
    String Frame._getLabel(int64 token) from "cwhip_gtk_frame_get_label"
    void Expander._setLabel(int64 token, String label) from "cwhip_gtk_expander_set_label"
    String Expander._getLabel(int64 token) from "cwhip_gtk_expander_get_label"
    void Expander._setExpanded(int64 token, bool expanded)
        from "cwhip_gtk_expander_set_expanded"
    bool Expander._getExpanded(int64 token) from "cwhip_gtk_expander_get_expanded"
    void TextView._setText(int64 token, String text) from "cwhip_gtk_text_view_set_text"
    String TextView._getText(int64 token) from "cwhip_gtk_text_view_get_text"
    void TextView._editable(int64 token, bool editable) from "cwhip_gtk_text_view_set_editable"
    bool TextView._getEditable(int64 token) from "cwhip_gtk_text_view_get_editable"
    void TextView._wrap(int64 token, bool wrap) from "cwhip_gtk_text_view_set_wrap"
    bool TextView._getWrap(int64 token) from "cwhip_gtk_text_view_get_wrap"
    void Entry._editable(int64 token, bool editable) from "cwhip_gtk_entry_editable"
    void Notebook._closable(int64 token, int64 child, String title, void<> close)
        from "cwhip_gtk_notebook_closable"
    void Notebook._bordered(int64 token) from "cwhip_gtk_notebook_bordered"
    void Notebook._scrollable(int64 token, bool enabled) from "cwhip_gtk_notebook_scrollable"
    bool Window._bindShortcut(int64 token, String trigger, void<> action)
        from "cwhip_gtk_window_bind_shortcut"
    bool Window._hasShortcut(int64 token, String trigger) from "cwhip_gtk_window_has_shortcut"
    void Window._clearWindowShortcuts(int64 token)
        from "cwhip_gtk_source_view_clear_shortcuts"
    bool Window._maximized(int64 token) from "cwhip_gtk_window_maximized"
    void Window._maximize(int64 token, bool enabled) from "cwhip_gtk_window_maximize"
    void Window._setMenubarAccel(int64 token, bool enabled)
        from "cwhip_gtk_window_handle_menubar_accel"
    bool Window._menubarAccel(int64 token)
        from "cwhip_gtk_window_handles_menubar_accel"
    bool SignalConnection._disconnect(int64 token) from "cwhip_gtk_connection_disconnect"
    bool SignalConnection._connected(int64 token) from "cwhip_gtk_connected"
    int64 Widget._create(int64 kind, String text, int64 orientation, int64 spacing, void<> root)
        from "cwhip_gtk_widget_create"
    void Widget._dispose(int64 token) from "cwhip_gtk_widget_dispose"
    bool Widget._disposed(int64 token) from "cwhip_gtk_widget_disposed"
    void Widget._visible(int64 token, bool value) from "cwhip_gtk_widget_visible"
    bool Widget._isVisible(int64 token) from "cwhip_gtk_widget_is_visible"
    void Widget._sensitive(int64 token, bool value) from "cwhip_gtk_widget_sensitive"
    void Widget._focusOnClick(int64 token, bool enabled) from "cwhip_gtk_widget_focus_on_click"
    void Widget._canFocus(int64 token, bool enabled) from "cwhip_gtk_widget_can_focus"
    void Widget._expand(int64 token, bool horizontal, bool value) from "cwhip_gtk_widget_expand"
    void Widget._widthRequest(int64 token, int64 width) from "cwhip_gtk_widget_width_request"
    void Widget._cssClass(int64 token, String name, bool add) from "cwhip_gtk_widget_css_class"
    void Widget._tooltip(int64 token, String text) from "cwhip_gtk_widget_tooltip"
    void Widget._focus(int64 token) from "cwhip_gtk_widget_focus"
    void Button._icon(int64 token, String name) from "cwhip_gtk_button_icon"
    int64 MenuBar._addMenu(int64 token, String label) from "cwhip_gtk_menu_add"
    int64 MenuBar._addItem(int64 token, int64 menu, String label, void<> action)
        from "cwhip_gtk_menu_item_add"
    void MenuBar._enabled(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_enabled"
    void MenuBar._activate(int64 token, int64 item) from "cwhip_gtk_menu_item_activate"
    void MenuBar._separator(int64 token, int64 menu) from "cwhip_gtk_menu_separator_add"
    int64 MenuBar._addCheck(int64 token, int64 menu, String label, bool initial, void<bool> action)
        from "cwhip_gtk_menu_check_add"
    void MenuBar._checked(int64 token, int64 item, bool value) from "cwhip_gtk_menu_item_set_checked"
    bool MenuBar._isChecked(int64 token, int64 item) from "cwhip_gtk_menu_item_checked"
    int64 MenuBar._addSubmenu(int64 token, int64 menu, String label) from "cwhip_gtk_menu_submenu_add"
    void MenuBar._clearMenu(int64 token, int64 menu) from "cwhip_gtk_menu_clear"
    int64 FileDialog._create(int64 parent, bool save, String initialPath, void<String> result)
        from "cwhip_gtk_file_dialog_create"
    int64 FileDialog._createMultiple(int64 parent, String initialPath, void<String> path)
        from "cwhip_gtk_file_dialog_create_multiple"
    int64 FileDialog._createFolder(int64 parent, String initialPath, void<String> result)
        from "cwhip_gtk_file_dialog_create_folder"
    void Paned._position(int64 token, int64 position) from "cwhip_gtk_paned_position"
    int64 Paned._getPosition(int64 token) from "cwhip_gtk_paned_get_position"
    bool Tree._isExpanded(int64 token, int64 id) from "cwhip_gtk_tree_is_expanded"
    int64 DirectoryScan._startFiltered(int64 owner, String path, bool hidden, String root,
        String excludes, void<int64, String> result) from "cwhip_gtk_directory_start_filtered"
    void Tree._setup(int64 token, void<int64> request, void<int64> activate)
        from "cwhip_gtk_tree_setup"
    void Tree._singleClick(int64 token, bool enabled) from "cwhip_gtk_tree_single_click"
    void Tree._add(int64 token, int64 parent, int64 id, String label, String icon, bool expandable, String value, int64 data)
        from "cwhip_gtk_tree_add"
    String Tree._value(int64 token, int64 id) from "cwhip_gtk_tree_value"
    int64 Tree._data(int64 token, int64 id) from "cwhip_gtk_tree_data"
    int64 Tree._find(int64 token, String value) from "cwhip_gtk_tree_find"
    int64 Tree._count(int64 token, int64 parent) from "cwhip_gtk_tree_count"
    void Tree._clear(int64 token, int64 parent) from "cwhip_gtk_tree_clear"
    void Tree._expandRow(int64 token, int64 id, bool expanded) from "cwhip_gtk_tree_expand"
    int64 DirectoryScan._start(int64 owner, String path, bool hidden, void<int64, String> result)
        from "cwhip_gtk_directory_start"
    void DirectoryScan._cancel(int64 token) from "cwhip_gtk_directory_cancel"
    void DirectoryScan._append(int64 token, int64 tree, int64 parent, int64 firstId, int64 count, String icons)
        from "cwhip_gtk_directory_append"
    void AlertDialog._show(int64 parent, String message, String detail) from "cwhip_gtk_alert_show"
    void FileDialog._cancel(int64 token) from "cwhip_gtk_file_dialog_cancel"
    bool FileDialog._pending(int64 token) from "cwhip_gtk_file_dialog_pending"
    void Widget._textSet(int64 token, String text) from "cwhip_gtk_widget_text_set"
    String Widget._textGet(int64 token) from "cwhip_gtk_widget_text_get"
    void Widget._attach(int64 parent, int64 child) from "cwhip_gtk_widget_attach"
    void Widget._remove(int64 parent, int64 child) from "cwhip_gtk_widget_remove"
    void Widget._windowAction(int64 token, int64 action) from "cwhip_gtk_window_action"
    void Widget._windowSize(int64 token, int64 width, int64 height) from "cwhip_gtk_window_size"
    int64 Widget._windowWidth(int64 token) from "cwhip_gtk_window_width"
    int64 Widget._windowHeight(int64 token) from "cwhip_gtk_window_height"
    void Widget._windowTransientFor(int64 token, int64 parent)
        from "cwhip_gtk_window_transient_for"
    void Widget._layout(int64 token, int64 orientation, int64 spacing) from "cwhip_gtk_box_layout"
    void Widget._activeSet(int64 token, bool value) from "cwhip_gtk_checkbox_set"
    bool Widget._activeGet(int64 token) from "cwhip_gtk_checkbox_get"
    void Widget._notebookAppend(int64 notebook, int64 child, String title)
        from "cwhip_gtk_notebook_append"
    int64 Widget._notebookCurrent(int64 notebook) from "cwhip_gtk_notebook_current"
    void Widget._notebookSetCurrent(int64 notebook, int64 page)
        from "cwhip_gtk_notebook_set_current"
    int64 Widget._notebookCount(int64 notebook) from "cwhip_gtk_notebook_count"
    void Widget._notebookTitle(int64 notebook, int64 page, String title)
        from "cwhip_gtk_notebook_title"
}
