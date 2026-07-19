; set_tool_lenght.g - Measure and set the length offset of the current tool
;
; Tool length setter: NC switch on io3.in (Duet 3 6XD), configured as probe K0 in config.g.
; The setter sits at machine X30 Y29 and its trigger surface is at machine Z = var.setterZ.
;
; RRF has no dedicated "measure tool length" G-code. This macro uses:
;   G30 S-1  -> probe down and REPORT the machine Z at trigger (changes nothing)
;   G10 Pn Z -> store the resulting tool Z offset
;
; Absolute method: the offset is set so the tool tip reads var.setterZ at the setter for
; every tool, keeping the workpiece Z-zero consistent across tool changes.
;
; Usage: select the tool first (e.g. T0), then run:  M98 P"set_tool_lenght.g"

; --- Setter location / trigger height (machine coordinates) ---
var setterX = 30
var setterY = 29
var setterZ = 14.7          ; measured machine Z at which the setter triggers

; --- Safety checks ---
if state.currentTool < 0
    abort "set_tool_lenght.g: no tool selected. Select a tool (e.g. T0) before running the tool setter."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "set_tool_lenght.g: home all axes (G28) before running the tool setter."

M400                             ; ensure any previous motion has finished

; Clear this tool's Z offset so we probe the raw (offset-free) reference point
G10 P{state.currentTool} Z0

; Always go to the top in Z first, then approach the setter in a straight line
G90                              ; absolute positioning
G53 G0 Z{move.axes[2].max}       ; raise to Z max (machine coords) for clearance
G53 G0 X{var.setterX} Y{var.setterY}   ; move over the setter (machine coords)

; Probe straight down; report the machine Z at trigger without altering position
G30 S-1 K0

; Machine Z where the offset-free reference point triggered
var trigZ = move.axes[2].machinePosition

; Offset so the tool tip reads the true setter height for all tools
var newOffset = { var.setterZ - var.trigZ }
G10 P{state.currentTool} Z{var.newOffset}

; Measured tool length as a positive value (longer tool -> larger number)
var toolLength = { -var.newOffset }

; Retract back to the top
G53 G0 Z{move.axes[2].max}

echo "Tool", state.currentTool, "length", var.toolLength, "mm (Z offset", var.newOffset, ", triggered at machine Z", var.trigZ, ")"

; Pop up a message with the tool number and the measured tool length
M291 P{"Tool " ^ state.currentTool ^ " measured. Tool length = " ^ var.toolLength ^ " mm"} R"Tool Setter" S1
