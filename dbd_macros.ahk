; =============================================================================
; AutoHotkey Macros for "Dead By Daylight" game
;
; Author     : Nicky Ramone
; Created    : Jan, 2019
; Last update: Mar, 2021
; =============================================================================

; ------------------------------------------------------------------------------------
; Macros summary
; ----------------------------------------------------------------------------------------------
; Action                        | Hotkey for enabling          | Hotkey for disabling
; ------------------------------+------------------------------+--------------------------------
; Hold M1                       | <Left Mouse Button> + <Tab>  | <Left/Right Mouse Click>
; Hold M2                       | <Right Mouse Button> + <Tab> | <Right/Right Mouse Click>
; Wiggle on killer's shoulders  | Hold <~>                     | Release <~>
; Struggle on hook              | <Tab>                        | <Tab>
; Flashlight spam               | Hold <Middle Mouse Button>   | Release <Middle Mouse Button>




; ------------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------------
GAME_WINDOW_TITLE := "DeadByDaylight"



; ------------------------------------------------------------------------------------
; Init
; ------------------------------------------------------------------------------------
toggle := False
holdingM1 := False
holdingM2 := False
tooltipMessages := {}




; ------------------------------------------------------------------------------------
; Macros
; ------------------------------------------------------------------------------------

#If WinActive(GAME_WINDOW_TITLE)

; =============================================================================
; Hold M1 or M2
; -------------
; Trigger: <Left/Right Mouse Button> + <Tab>
; =============================================================================
Tab::
	lButtonDown := GetKeyState("LButton", "P")
	rButtonDown := GetkeyState("RButton", "P")

	if (lButtonDown) {
		ShowToolTip("hold-m1", "Holding M1...")
		holdingM1 := True
	}
	else if (rButtonDown) {
		ShowToolTip("hold-m2", "Holding M2...")
		holdingM2 := True
	}
	else {
		CheckStruggleOnHook()
	}
	return

*LButton::
	if (holdingM2) {
		Click,, Right,, Up
		holdingM2 := False
		ClearTooltip("hold-m2")
	}
	if (holdingM1) {
		ClearTooltip("hold-m1")
		holdingM1 := False
	}
	Click,, Left,, Down
	return

LButton Up::
	if (holdingM1) {
		return
	}
	Send, {LButton Up}
	return
	
*RButton::
	if (holdingM1) {
		Click,, Left,, Up
		holdingM1 := False
		ClearTooltip("hold-m1")
	}
	if (holdingM2) {
		ClearTooltip("hold-m2")
		holdingM2 := False
	}
	Click,, Right,, Down
	return

RButton Up::
	if (holdingM2) {
		return
	}
	Send, {RButton Up}
	return


; =============================================================================
; Struggle on hook
; ----------------
; Toggle: <Tab>
;
; Description:
;   When placed on the hook, press the toggle hotkey to enable automatic
;   struggling.  When you are done, press the key combination again to disable.
;
;   Once struggling is enabled, you can <Alt> + <Tab> to other windows, but
;   you shouldn't use Steam's overlay (<Shift> + <Tab>). The overlay overrides
;   the game control, so that means that you will be sending "space" key to the
;   Steam app instead of the game, and you will die.
;   If you need to use Steam chat, for example, be sure to switch to steam by
;   using <Alt> + <Tab>. That will take you to the real Steam window and the
;   DBD window will remain intact in the background.
; =============================================================================
CheckStruggleOnHook() {
	global toggle

	if (toggle) {
		toggle := False
		SetTimer, StruggleOnHook, off
		ClearTooltip("struggle")
	}
	else {
		ShowToolTip("struggle", "Struggling...")
		toggle := True
		SetTimer, StruggleOnHook, 200
	}
}

StruggleOnHook:
	ControlSend,, {space}, % GAME_WINDOW_TITLE
	return



; =============================================================================
; Wiggle on killer's shoulders
; ----------------------------
; Trigger: Hold <~>
; =============================================================================
SC029::
	ShowToolTip("wiggle", "Wiggling...")
	tildeKey := GetKeyName("SC029")

	while GetKeyState(tildeKey, "P") {
		Send {a down} 
		Sleep, 50
		Send {a up}
		Sleep, 50
		Send {d down}
		Sleep, 50
		Send {d up}
		Sleep, 50
	}
	ClearTooltip("wiggle")
	return




; =============================================================================
; Flashlight spam
; ---------------
; Trigger: Hold down mouse wheel.
; =============================================================================
; The default is 10 (ms) but for flashlight spamming we want clicks to be faster.
SetMouseDelay, 0
*MButton::
	while GetKeyState("MButton", "P")
	{
		MouseClick, Right
	}
	return




; =============================================================================
; Cancel toggleable action
; ------------------------
; Trigger: <Esc>
;
; Description: Cancels any action that is currently running depending on the
; 'toggle' variable.
; =============================================================================
$Escape::
	global toggle

	if (toggle) {
		toggle := False
		ClearToolTips()
	}
	else {
		Send, {esc}
	}
	return


ShowTooltip(key, message) {
	global tooltipMessages
	tooltipMessages[key] := message
	DisplayAllTooltips()
}


ClearTooltips() {
	global tooltipMessages
	tooltipMessages := {}
	ToolTip
}

ClearTooltip(key) {
	global tooltipMessages
	tooltipMessages.Delete(key)
	DisplayAllTooltips()
}

DisplayAllTooltips() {
	global tooltipMessages
	tooltip := ""

	for key, msg in tooltipMessages {
		tooltip := tooltip msg "`n"
	}

	coords := GetScreenCoords(0.45, 0.01)
	Tooltip, %tooltip%, coords[1], coords[2]
}

GetScreenCoords(xPercent, yPercent) {
	windowWidth := 0
	windowHeight := 0
	WinGetPos,,, windowWidth, windowHeight, % GAME_WINDOW_TITLE
	return [windowWidth * xPercent, windowHeight * yPercent]
}
