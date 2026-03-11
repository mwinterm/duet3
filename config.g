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
; X-Axis: 1x 1HCL at CAN address 41
M569 P41.0 S1                      ; X drive goes forward
M584 X41.0                         ; Map X axis to drive 41.0
M350 X16 I1                        ; Configure microstepping with interpolation
M92 X53.333                        ; Set steps per mm
M566 X9000                         ; Set maximum instantaneous speed changes (mm/min)
M203 X18000                        ; Set maximum speeds (mm/min)
M201 X1000                         ; Set accelerations (mm/s^2)
M906 X3000 I30                     ; Set motor currents (mA), idle 30%

; Z-Axis: 1x 1HCL at CAN address 44
M569 P44.0 S1                      ; Z drive goes forward
M584 Z44.0                         ; Map Z axis to drive 44.0
M350 Z16 I0                        ; Configure microstepping without interpolation
M92 Z685.712                       ; Set steps per mm
M566 Z120                          ; Set maximum instantaneous speed changes (mm/min)
M203 Z2400                         ; Set maximum speeds (mm/min)
M201 Z250                          ; Set accelerations (mm/s^2)
M906 Z2000 I30                     ; Set motor currents (mA), idle 30%

; --- Axis Limits ---
M208 X0 Z0 S1                      ; Set axis minima
M208 X610 Z140 S0                  ; Set axis maxima

; --- Endstops ---
M574 X1 S1 P"^41.io0.in"           ; X endstop at low end, active high, on 41.io0.in with pullup
M574 Z2 S1 P"^44.io0.in"           ; Z endstop at high end, active high, on 44.io0.in with pullup

M84 S30                             ; Set idle timeout (seconds)

; Define Tool 0
M563 P0 S"G-Penny" R0
G10 P0 R6000 S0
T0