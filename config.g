; Configuration for Duet 3 6XD Standalone
M550 P"MyCNC"               ; Machine name

; Network
M552 S1                     ; Enable Ethernet (DHCP)
M586 P0 S1                  ; Enable HTTP (Web Interface)

; PanelDue (Connected to IO_0)
; WAS: M575 P1... (Wrong, P1 is RS485)
; NOW: M575 P0... (Correct, P0 is IO_0)
M575 P0 S1 B57600           

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

; Define Tool 0
M563 P0 S"G-Penny" R0
G10 P0 R6000 S0
T0