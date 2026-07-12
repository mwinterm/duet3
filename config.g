; Configuration for Duet 3 6XD Standalone
M550 P"MyCNC"               ; Machine name

; Network
M552 S1                     ; Enable Ethernet (DHCP)
M586 P0 S1                  ; Enable HTTP (Web Interface)

; PanelDue (Connected to IO_0, uses P1 on 6XD)
M575 P1 S1 B57600           

; --- Emergency Stop Setup ---
; NC Switch on io2.in. ^ enables pull-up.
M950 J1 C"^io2.in"          
M581 P1 T2 S1 R0            ; Trigger 2 = custom macro (stops VFD before M112)            

; Abort startup if E-stop is pressed
; M950 J1 used, so we check gpIn[1]. NC switch: 0=Connected(Safe), 1=Open(Stop)
if sensors.gpIn[1].value = 1
    abort "E-Stop is pressed! Release E-Stop and restart."

; --- Spindle Configuration ---
; H100 VFD via RS485 Modbus RTU on IO1 header
; IO1 is shared with RS485 - do not use IO1 for endstops
M575 P2 B9600 S7            ; P2=IO1 (RS485), B9600=baud, S7=Modbus RTU

; Create Spindle 0 using VFD output pin
; L0:24000 = RPM range, Q1000 = PWM frequency (not used by Modbus but required)
M950 R0 C"vfd" L0:24000 Q1000

; Global variables for daemon.g VFD state tracking
global vfdState = "stopped"
global vfdFreq = 0
global vfdActualRPM = 0

; --- Drive Configuration ---
; All drives run in OPEN-LOOP stepper mode (D2 = spreadCycle).
; No feedback is used from the rotary (magnetic) or linear encoders.

G4 S2                              ; Wait for CAN expansion boards (41-44) to start up before configuring them

; X-Axis: 1x 1HCL at CAN address 41 (open-loop)
M569 P41.0 S1 D2                   ; X drive forward, D2 = open-loop spreadCycle
M584 X41.0                         ; Map X axis to drive 41.0
M350 X16 I1                        ; Configure microstepping with interpolation
M92 X53.4238                        ; Set steps per mm
M566 X9000                         ; Set maximum instantaneous speed changes (mm/min)
M203 X18000                        ; Set maximum speeds (mm/min)
M201 X1000                         ; Set accelerations (mm/s^2)
M906 X3000 I30 T30                 ; Set motor currents (mA), idle 30%, idle timeout 30s

; Y-Axis: 2x 1HCL at CAN addresses 42 and 43 in tandem (open-loop)
M569 P42.0 S0 D2                   ; Y1 drive backwards, D2 = open-loop spreadCycle
M569 P43.0 S1 D2                   ; Y2 drive forward, D2 = open-loop spreadCycle
M584 Y42.0:43.0                    ; Map Y axis to drives 42.0 and 43.0
M350 Y16 I1                        ; Configure microstepping with interpolation
M92 Y53.4238                       ; Set steps per mm
M566 Y9000                         ; Set maximum instantaneous speed changes (mm/min)
M203 Y18000                        ; Set maximum speeds (mm/min)
M201 Y1000                         ; Set accelerations (mm/s^2)
M906 Y3000 I30 T30                 ; Set motor currents (mA), idle 30%, idle timeout 30s

; Z-Axis: 1x 1HCL at CAN address 44 (open-loop)
M569 P44.0 S1 D2                   ; Z drive forward, D2 = open-loop spreadCycle
M584 Z44.0                         ; Map Z axis to drive 44.0
M350 Z16 I0                        ; Configure microstepping without interpolation
M92 Z685.712                       ; Set steps per mm
M566 Z120                          ; Set maximum instantaneous speed changes (mm/min)
M203 Z2400                         ; Set maximum speeds (mm/min)
M201 Z250                          ; Set accelerations (mm/s^2)
M906 Z2000 I30 T30                 ; Set motor currents (mA), idle 30%, idle timeout 30s

; --- Axis Limits ---
M208 X0 Y0 Z0 S1                      ; Set axis minima
M208 X610 Y1925 Z140 S0               ; Set axis maxima

; --- Endstops ---
M574 X1 S1 P"^41.io0.in"           ; X endstop (NC) at low end, active high, on 41.io0.in with pullup
M574 Y1 S1 P"^42.io0.in+^43.io0.in" ; Y endstops (NC) at low end, active high, on 42 and 43 io0.in with pullup
M574 Z2 S1 P"^44.io0.in"           ; Z endstop at high end, active high, on 44.io0.in with pullup

; --- Z-Probe / Tool Probe ---
M558 P8 C"^io3.in" H5 F120 T3000   ; P8=switch, ^ enables pull-up on io3.in for NO probe
G31 P500 X0 Y0 Z0                  ; Set Z probe trigger value, offset and trigger height

; Idle timeout is now set via the M906 T parameter above (M84 S is deprecated in RRF 3.6)

; Define Tool 0
M563 P0 S"G-Penny" R0
G10 P0 R6000 S0
T0