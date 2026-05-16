# Pepsi UI Library
> A feature-rich Roblox UI library for creating clean, themeable script GUIs.

**Version:** `0.37`

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Window](#window)
- [Tab](#tab)
- [Section](#section)
- [Elements](#elements)
  - [Toggle](#toggle)
  - [Button](#button)
  - [Slider](#slider)
  - [Textbox](#textbox)
  - [Dropdown](#dropdown)
  - [SearchBox](#searchbox)
  - [Colorpicker](#colorpicker)
  - [Keybind](#keybind)
  - [Label](#label)
  - [Persistence](#persistence)
- [Designer](#designer)
- [Notifications](#notifications)
- [Prompts](#prompts)
- [Utility / Subs](#utility--subs)
- [Global Library Properties](#global-library-properties)
- [Unloading](#unloading)

---

## Installation

Load the library via `loadstring` or a `require` call in your Roblox script executor:

```lua
local library = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
```

The library returns three values:

```lua
local library, flags, subs = loadstring(...)()
```

| Return | Description |
|--------|-------------|
| `library` | Main library table |
| `flags` | Shorthand for `library.flags` — stores all element values |
| `subs` | Shorthand for `library.subs` — utility functions |

---

## Quick Start

```lua
local library = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()

local Window  = library:CreateWindow({ Name = "My Script" })
local Tab     = Window:CreateTab({ Name = "Main" })
local Section = Tab:CreateSection({ Name = "Combat" })

Section:AddToggle({
    Name     = "God Mode",
    Value    = false,
    Flag     = "GodMode",
    Callback = function(value)
        print("God Mode:", value)
    end
})

-- Access any flag value at any time:
print(library.flags["GodMode"]) -- true / false
```

---

## Window

```lua
local Window = library:CreateWindow(options)
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Name` | `string` | `"Window Name"` | Title displayed in the window header |
| `Theme` / `DefaultTheme` | `JSON string` or `table` | `nil` | Pre-load a theme on startup |
| `Themeable` | `boolean` or `table` | `nil` | Enables the Designer tab; pass a table for designer options |
| `StartLocationUDim2` | `UDim2` | `UDim2.fromScale(0.5, 0.5)` | Starting position of the window |
| `LockTheme` | `boolean` | `nil` | Hides color/background controls in Designer |
| `HideTheme` | `boolean` | `nil` | Hides the entire Designer tab |

### Methods

| Method | Description |
|--------|-------------|
| `Window:CreateTab(options)` | Creates and returns a new Tab |
| `Window:CreateDesigner(options)` | Creates the Designer/theme tab |
| `Window:Show()` | Makes the window visible |
| `Window:Hide()` | Hides the window |
| `Window:Visibility(bool?)` | Toggles or sets visibility |
| `Window:MoveTabSlider(tabObject)` | Animates the tab underline slider |
| `Window:UpdateAll()` | Calls `Update()` on all elements |
| `Window.GoHome` | Function — navigates to the first tab |
| `Window.Flags` | Table of all registered element objects |

---

## Tab

```lua
local Tab = Window:CreateTab(options)
```

### Options

| Option | Type | Description |
|--------|------|-------------|
| `Name` | `string` | Tab label text |
| `Image` | `string` / `number` | Optional icon asset ID |
| `TabOrder` | `number` | Layout order override |

### Methods

| Method | Description |
|--------|-------------|
| `Tab:CreateSection(options)` | Creates and returns a Section |
| `Tab:UpdateAll()` | Updates all elements inside the tab |
| `Tab.Select()` | Programmatically switches to this tab |
| `Tab.Flags` | Table of element objects belonging to this tab |

---

## Section

```lua
local Section = Tab:CreateSection(options)
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Name` | `string` | `"Section Name"` | Label shown on the section border |
| `Side` | `"Left"` / `"Right"` | `"Left"` | Which column the section appears in |

### Methods

| Method | Description |
|--------|-------------|
| `Section:Update()` | Recalculates section height and canvas size |
| `Section:UpdateAll()` | Updates all child elements then the section |
| `Section.Flags` | Table of element objects inside this section |

---

## Elements

All element constructors follow the same pattern:

```lua
local Element = Section:AddXxx({ ...options })
```

Every element exposes these common members:

| Member | Description |
|--------|-------------|
| `Element.Options` | The original options table |
| `Element.Type` | String name of the element type |
| `Element.Name` / `.Flag` | The flag key used in `library.flags` |
| `Element.Default` | The initial/default value |
| `Element.Parent` | The parent Section |
| `Element.Instance` | The primary Roblox UI instance |
| `Element:Get()` | Returns the current value |
| `Element:Set(value)` | Sets the value and fires the callback |
| `Element:RawSet(value)` | Sets the value **without** firing the callback |
| `Element:Reset()` | Resets the element to its default value |
| `Element:Update()` | Refreshes the UI to match the current flag value |
| `Element:Remove()` | Removes the element from the UI |

---

### Toggle

```lua
local Toggle = Section:AddToggle({
    Name     = "My Toggle",   -- Required
    Value    = false,         -- Initial state
    Flag     = "MyToggle",
    Callback = function(newValue, oldValue) end,
    Locked   = false,         -- Greys out and disables interaction
    Keybind  = {              -- Optional inline keybind
        Value    = Enum.KeyCode.F,
        Mode     = "Toggle",  -- "Toggle" | "Hold" | "Dynamic"
        Callback = function(newKey, oldKey) end,
        Pressed  = function() end,
    },
    Condition = function(newValue, oldValue)
        return true -- return false to block the state change
    end,
    AllowDuplicateCalls = false,
    Location    = someTable,  -- Mirror value into this table
    LocationFlag = "KeyName",
    UnloadValue = false,      -- Value applied on library unload
    UnloadFunc  = function() end,
})
```

#### Extra Methods

| Method | Description |
|--------|-------------|
| `Toggle:Lock()` | Disables the toggle |
| `Toggle:Unlock()` | Re-enables the toggle |
| `Toggle:SetLocked(bool)` | Locks or unlocks |
| `Toggle:SetCondition(fn)` | Replaces the condition function |
| `Toggle.KeybindData` | Reference to the attached keybind element (if any) |

---

### Button

```lua
local Button = Section:AddButton(
    { Name = "Click Me", Callback = function(presses) end },
    { Name = "Right Click", Callback = function(presses) end } -- optional second button on same row
)
```

#### Options (per button)

| Option | Type | Description |
|--------|------|-------------|
| `Name` | `string` | Button label |
| `Callback` | `function(presses)` | Called on left-click |
| `CallbackRight` | `function(presses)` | Called on right-click |
| `Condition` | `function(presses) → bool` | Blocks press if returns false |
| `MouseEnterCallback` | `function` | Called on hover enter |
| `MouseLeaveCallback` | `function` | Called on hover leave |
| `Locked` | `boolean` | Disables the button |

#### Methods

| Method | Description |
|--------|-------------|
| `Button:Press(...)` | Fires the callback programmatically |
| `Button:RawPress(...)` | Fires the callback without incrementing press count |
| `Button:Lock()` / `:Unlock()` | Disable / enable |
| `Button:SetText(str)` | Changes the button label |
| `Button:SetCallback(fn)` | Replaces the callback |
| `Button.PressAll()` | Presses every button in a multi-button row |

---

### Slider

```lua
local Slider = Section:AddSlider({
    Name     = "Speed",   -- Required
    Min      = 0,         -- Required
    Max      = 100,       -- Required
    Value    = 50,
    Flag     = "Speed",
    Callback = function(value, oldValue) end,
    Decimals = 1,         -- Decimal precision
    Format   = "Speed: %s studs/s",  -- or function(v) return tostring(v) end
    Textbox  = true,      -- Show manual input box
    AllowDuplicateCalls = false,
})
```

#### Extra Methods

| Method | Description |
|--------|-------------|
| `Slider:SetMin(n)` | Changes the minimum bound |
| `Slider:SetMax(n)` | Changes the maximum bound |
| `Slider:SetConstraints(min, max)` | Changes both bounds at once |

---

### Textbox

```lua
local Textbox = Section:AddTextbox({
    Name        = "Player Name",  -- Required
    Value       = "Pepsi",
    Flag        = "PlayerName",
    Placeholder = "Enter name...",
    Callback    = function(newValue, oldValue, textboxInstance) end,
    Type        = "number",       -- Treats input as a number
    Min         = 0,
    Max         = 999,
    Decimals    = 0,
    MultiLine   = false,
    RichText    = false,
    AllowDuplicateCalls = false,
})
```

---

### Dropdown

```lua
local Dropdown = Section:AddDropdown({
    Name     = "Team",       -- Required
    List     = {"Red", "Blue", "Green"},  -- Required; also accepts Instance, Enum, or function
    Value    = "Red",
    Flag     = "Team",
    Callback = function(newValue, oldValue) end,
    Multi    = false,        -- Enable multi-select
    Sort     = true,         -- Alphabetical sort; or pass a custom sort function
    BlankValue = "None",     -- Optional placeholder entry
    AllowDuplicateCalls = false,

    -- Multi-select callbacks:
    ItemAdded   = function(item, allSelected) end,
    ItemRemoved = function(item, allSelected) end,
    ItemChanged = function(item, isSelected, allSelected) end,
    ItemsCleared = function(allSelected, previous) end,
})
```

#### Extra Methods

| Method | Description |
|--------|-------------|
| `Dropdown:UpdateList(newList, validate?)` | Replaces the item list at runtime |
| `Dropdown:Validate(fallback?)` | Checks if the current value is still in the list |

---

### SearchBox

Identical to Dropdown but with a live-filter text input instead of a static label.

```lua
local SearchBox = Section:AddSearchBox({
    Name  = "Find Player",
    List  = game.Players:GetPlayers(),
    Flag  = "TargetPlayer",
    Callback = function(value, old) end,
    RegEx = false,   -- Enable Lua pattern matching in the search field
    -- All other Dropdown options are supported
})
```

---

### Colorpicker

```lua
local Colorpicker = Section:AddColorpicker({
    Name     = "ESP Color",  -- Required
    Value    = Color3.fromRGB(255, 0, 0), -- or "rainbow" / "random"
    Flag     = "EspColor",
    Callback = function(newColor, oldColor) end,
    Rainbow  = false,
    AllowDuplicateCalls = false,
})
```

#### Extra Methods

| Method | Description |
|--------|-------------|
| `Colorpicker:SetRainbow(bool?)` | Enables or toggles rainbow mode |
| `Colorpicker:GetRainbow()` | Returns `true` if rainbow mode is active |

---

### Keybind

```lua
local Keybind = Section:AddKeybind({
    Name    = "Toggle Fly",  -- Required
    Value   = Enum.KeyCode.F,
    Flag    = "FlyKey",
    Callback = function(newKey, oldKey) end,
    Pressed  = function(inputObject, gameProcessed) end,
    AllowDuplicateCalls = false,
})
```

> Users can click the keybind label to rebind. Press `Escape` or `Backspace` to clear.

---

### Label

```lua
local Label = Section:AddLabel({
    Text = "Status: Idle",
    Flag = "StatusLabel",
})

-- Update the label text at runtime:
Label:Set("Status: Active")
```

---

### Persistence

Persistence adds Save/Load buttons backed by the local file system. Requires executor file functions (`readfile`, `writefile`, `listfiles`, etc.).

```lua
local Persistence = Section:AddPersistence({
    Name    = "Config",      -- Required
    Flag    = "ConfigFile",
    Flags   = "all",         -- "all" | "tab" | "section" | table of flag names
    Workspace = "MyScript",  -- Sub-folder name inside Pepsi Lib/
    Suffix  = "Config",      -- Appended to Save/Load button labels

    LoadCallback     = function(filePath, currentValue) end,
    SaveCallback     = function(filePath, currentValue) end,
    PostLoadCallback = function(filePath, currentValue) end,
    PostSaveCallback = function(filePath, currentValue) end,
})
```

#### Methods

| Method | Description |
|--------|-------------|
| `Persistence:SaveFile(name?)` | Saves flags to a `.txt` file |
| `Persistence:LoadFile(name?)` | Loads flags from a `.txt` file |
| `Persistence:LoadJSON(json)` | Loads flags from a raw JSON string |
| `Persistence:LoadFileRaw(name?)` | Loads using `RawSet` (no callbacks) |
| `Persistence:LoadJSONRaw(json)` | Loads JSON using `RawSet` |
| `Persistence:GetJSON(fn?)` | Returns the current config as a JSON string; pass `true` to copy to clipboard |

---

## Designer

The Designer is a built-in theming panel attached as the last tab.

```lua
-- Minimal — just show the designer tab
Window:CreateDesigner()

-- With options
Window:CreateDesigner({
    Image  = "rbxassetid://7483871523",
    Credit = true,
    Info   = "My script v1.0",
    Background = {
        Asset        = "rbxassetid://1234567",
        Transparency = 0.5,
        Visible      = true,
    },
})

-- Or enable it automatically via CreateWindow:
local Window = library:CreateWindow({
    Name      = "My Script",
    Themeable = true,          -- Shows designer with defaults
})
```

### Designer Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `SetBackground` | `(Asset?, Transparency?, Visible?)` | Updates the backdrop image at runtime |

### Theme JSON

Copy the current theme from the Designer panel ("Copy Theme" button) and paste it as `DefaultTheme` in `CreateWindow`:

```lua
local Window = library:CreateWindow({
    Name         = "My Script",
    DefaultTheme = '{"__Designer.Colors.main":"FF2727",...}',
})
```

---

## Notifications

```lua
local Notification = library:Notify({
    Text   = "Hello World!",
    Time   = 6,             -- Duration in seconds
    Paused = false,         -- Pause the timer immediately
})
```

### Notification Methods

| Method | Description |
|--------|-------------|
| `Notification:SetText(str)` | Updates the displayed text |
| `Notification:AddTime(seconds)` | Extends the notification timer |
| `Notification:SetPaused(bool?)` | Pauses or resumes the timer |
| `Notification:Hide()` | Hides the notification frame |
| `Notification:Show()` | Shows the notification frame |
| `Notification:Destroy()` | Immediately removes it |
| `Notification.OnClose` | RBXScriptSignal — fires when the × is clicked |

---

## Prompts

```lua
local Prompt = library:Prompt({
    Name        = "Confirm",
    Description = "Are you sure you want to reset?",
    CloseButton = true,
    Timeout     = 10,   -- Auto-close after N seconds
    Options = {
        Yes = { Callback = function() print("confirmed") end },
        No  = { Callback = function() print("cancelled") end },
    },
})

-- Listen for a selection:
Prompt.OnSelect:Connect(function(key, text)
    print("User selected:", key)
end)
```

---

## Utility / Subs

Accessible via `library.subs` or `library.Subs`.

| Function | Signature | Description |
|----------|-----------|-------------|
| `updatecolors` | `(tweenTime?)` | Re-applies all theme colors |
| `Wait` | `(time?)` | `wait()` that returns `false` if the library is unloaded |
| `removeSpaces` | `(str) → str` | Strips spaces from a string |
| `Color3ToHex` | `(Color3) → string` | Converts a Color3 to a hex string |
| `Color3FromHex` | `(string) → Color3` | Parses a hex string into a Color3 |
| `textToSize` | `(TextLabel) → Vector2` | Measures text bounds |
| `makeDraggable` | `(topBar, frame)` | Makes a frame draggable |
| `ResolveID` | `(image, flag?)` | Resolves an asset ID string |
| `GetPath` | `(Instance) → string` | Encodes an instance path |
| `ResolvePath` | `(string) → Instance` | Decodes an instance path |
| `Instance_new` | `(class, parent?)` | Creates a protected instance tracked for unload cleanup |
| `SeverAllConnections` | `(table)` | Disconnects all signals in a table |
| `GetResolver` | `(list, filter, method)` | Returns a list-resolver function used by dropdowns |
| `ConvertFilename` | `(str, default?, replace?)` | Sanitizes a string for use as a filename |

---

## Global Library Properties

| Property | Type | Description |
|----------|------|-------------|
| `library.flags` | `table` | All current element values, keyed by flag name |
| `library.colors` | `table` | Theme color map; assigning a key triggers an auto-repaint |
| `library.signals` | `table` | All active RBXScriptConnections — auto-disconnected on unload |
| `library.objects` | `table` | All created Instances — auto-destroyed on unload |
| `library.configuration` | `table` | Runtime config: `hideKeybind`, `smoothDragging`, `easingStyle`, `easingDirection` |
| `library.LP` | `Player` | LocalPlayer reference |
| `library.Mouse` | `Mouse` | LocalPlayer mouse |
| `library.Version` | `string` | Current library version string |
| `library.WorkspaceName` | `string` | Folder name used for saved configs (`"Pepsi Lib"` by default) |
| `library.UnloadCallback` | `function` | Called just before the library unloads |

### Hiding the Window

Press **RightShift** (default) to toggle window visibility. Rebindable via the Designer's Settings section or:

```lua
library.configuration.hideKeybind = Enum.KeyCode.RightControl
```

---

## Unloading

```lua
library:Unload()         -- Unload this library instance
library.unloadall()      -- Unload ALL active library instances
```

On unload the library will:
1. Call `UnloadCallback` if set.
2. Apply `UnloadValue` / `UnloadFunc` for each element that has one.
3. Disconnect all signals in `library.signals`.
4. Destroy all instances in `library.objects`.

---

## License

This library was created by **Pepsi#5229**. Removing the in-Designer credit is supported via `Credit = false`, but attribution is appreciated.
