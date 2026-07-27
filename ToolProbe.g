; ToolProbe.g - Measure and set the length offset of the current tool
;
; T1..T49 (cutting tools): probes the tool setter (NC switch on io3.in, probe K0)
;   at machine X30 Y29. The tool tip presses the setter pad until the K0 switch fires.
;
; T0 (touch probe): the setter switch must NOT be used (K0 probing would keep pushing
;   the stylus until the switch actuates - wrong measurement, possible overtravel damage).
;   Instead the rigid reference surface at machine X30 Y45 is probed using the probe's
;   OWN trigger (K1). The surface sits (almost) exactly at the setter's trigger plane;
;   var.probeCorrection absorbs the small residual (if cuts come out d mm too DEEP after
;   zeroing with the probe, INCREASE var.probeCorrection by d).
;
; Both paths store the offset with the SAME formula and the SAME zero-length-tool datum:
;   G30 S-1  -> probe down and REPORT the machine Z at trigger (no datum change)
;   G10 Pn Z{var.setterZ - trigZ}  -> store the tool Z offset
; so probe readings and cutting tool lengths stay consistent: zero the WCS with T0 and
; every setter-measured tool cuts at the right depth. G31 K1 Z stays 0 in config.g.
;
; Usage: select the tool first (T0 for the probe, e.g. T1 for a cutter), then run:
;   M98 P"ToolProbe.g"

; --- Zero-length-tool datum (machine coordinates) ---
var setterZ = -28.147       ; machine Z at which a zero-length tool would trigger the setter
                            ; (calibrated so a 39.22 mm tool triggering at machine Z 11.073 reports 39.22)

; --- Tool setter location (cutting tools, probe K0) ---
var setterX = 30
var setterY = 29

; --- Rigid reference surface (touch probe T0, probe K1) ---
var probeX = 30
var probeY = 45
var probeCorrection = -0.402 ; small residual correction (mm); +d if cuts are d too deep

; --- Safety checks ---
if state.currentTool < 0
    abort "ToolProbe.g: no tool selected. Select a tool (T0 = probe, T1.. = cutter) before running."
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "ToolProbe.g: home all axes (G28) before measuring."

M400                             ; ensure any previous motion has finished

; Clear this tool's Z offset so we probe the raw (offset-free) reference point
G10 P{state.currentTool} Z0

; Always go to the top in Z first, then approach in a straight line
G90                              ; absolute positioning
G53 G0 Z{move.axes[2].max}       ; raise to Z max (machine coords) for clearance

if state.currentTool == 0
    ; Touch probe: probe the rigid reference surface with the probe's own trigger (K1),
    ; from the top at the normal probing speeds (same as a tool measurement - a homed
    ; G30 probes the full travel down to just below Z min, see GCodes4.cpp probingAtPoint3)
    G53 G0 X{var.probeX} Y{var.probeY}          ; move over the reference surface
    G30 K1 S-1                                  ; probe; stop on trigger, change no datum
else
    ; Cutting tool: probe the tool setter switch (K0)
    G53 G0 X{var.setterX} Y{var.setterY}        ; move over the setter
    G30 K0 S-1                                  ; probe; stop on trigger, change no datum

; Machine Z where the offset-free reference point triggered
var trigZ = move.axes[2].machinePosition

; Offset on the common datum (plus the residual correction for the touch probe)
var newOffset = { var.setterZ - var.trigZ + (state.currentTool == 0 ? var.probeCorrection : 0) }
G10 P{state.currentTool} Z{var.newOffset}

; Persist tool offsets (P10) and probe trigger heights (P31) to config-override.g
M500 P10:31

; Measured tool length as a positive value (longer tool -> larger number)
var toolLength = { -var.newOffset }

; Retract back to the top
G53 G0 Z{move.axes[2].max}

if state.currentTool == 0
    M291 P{"Touch probe T0 calibrated. Probe length = " ^ var.toolLength ^ " mm (triggered at machine Z " ^ var.trigZ ^ ", correction " ^ var.probeCorrection ^ ")"} R"Probe Calibration" S1
else
    M291 P{"Tool " ^ state.currentTool ^ " measured. Tool length = " ^ var.toolLength ^ " mm (triggered at machine Z " ^ var.trigZ ^ ")"} R"Tool Setter" S1
