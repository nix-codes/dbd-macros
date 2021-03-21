; =============================================================================
; AutoHotkey macros for "Dead By Daylight" game
;
; Author     : Nicky Ramone
; Created    : Jan, 2019
; Last update: Mar, 2021
; Revision   : 2
; =============================================================================

; --------------------------------------------------------------------------------------------------
; Macros summary
; --------------------------------------------------------------------------------------------------
; Action                        | Hotkey for enabling               | Hotkey for disabling
; ------------------------------+-----------------------------------+-------------------------------
; Hold M1                       | Hold <Left Mouse Button> + <Tab>  | <Left/Right Mouse Click>
; Hold M2                       | Hola <Right Mouse Button> + <Tab> | <Right/Right Mouse Click>
; Wiggle on killer's shoulders  | Hold <~>                          |
; Struggle on hook              | <Tab>                             | <Tab>
; Flashlight spam               | Hold <Middle Mouse Button>        |
; --------------------------------------------------------------------------------------------------




; ------------------------------------------------------------------------------------
; Constants
; ------------------------------------------------------------------------------------
GAME_WINDOW_TITLE := "DeadByDaylight"



; ------------------------------------------------------------------------------------
; Init
; ------------------------------------------------------------------------------------
toggle := False
struggling := False
ttip := new MultiTooltip()
mouse_button_lock_manager := new MouseButtonLockManager(ttip)
return



; ------------------------------------------------------------------------------------
; Macros
; ------------------------------------------------------------------------------------


#If WinActive(GAME_WINDOW_TITLE)



SC029::
	WiggleOnKillersShoulders()
	return

*MButton::
	SpamFlashlight()
	return

Tab::
	if (mouse_button_lock_manager.toggleLock()) {
		if (struggling) {
			ToggleStruggleOnHook()
		}
	}
	else {
		ToggleStruggleOnHook()	
	}
	return

*LButton::
	mouse_button_lock_manager.notifyLeftButtonDown()
	return

LButton Up::
	mouse_button_lock_manager.notifyLeftButtonUp()
	return

*RButton::
	mouse_button_lock_manager.notifyRightButtonDown()
	return

RButton Up::
	mouse_button_lock_manager.notifyRightButtonUp()
	return
	
$Escape::
	CancelToggleableAction()
	return


; =============================================================================
; Flashlight spam
; =============================================================================
; The default is 10 (ms) but for flashlight spamming we want clicks to be faster.
SpamFlashlight() {
	global ttip
	ttip.add("flashlight-spam", "Spamming flashlight")
	SetMouseDelay, 0
	while GetKeyState("MButton", "P")
	{
		MouseClick, Right
	}
	SetMouseDelay, 10
	ttip.remove("flashlight-spam")
}


; =============================================================================
; Struggle on hook
; ----------------
; Description:
;   Automatically struggles while survivor is on hook.
;
;   Once the struggling is enabled, you can <Alt> + <Tab> to other windows but
;   you shouldn't use Steam's overlay (<Shift> + <Tab>). The overlay overrides
;   the game control, so that means that you will be sending "space" key to the
;   Steam app instead of the game, and you will die.
;   If -for example- you need to use Steam chat while struggling, be sure to 
;   switch to Steam by using <Alt> + <Tab>. That will take you to the real Steam
;   window and the DBD window will remain intact in the background.
; =============================================================================
ToggleStruggleOnHook() {
	global struggling, ttip
	static timerFn := Func("PressSpaceOnWindow")

	if (struggling) {
		struggling := False
		SetTimer, %timerFn%, off
		ttip.remove("struggle")
	}
	else {
		ttip.add("struggle", "Struggling...")
		struggling := True
		SetTimer, %timerFn%, 200
	}
}


PressSpaceOnWindow() {
	global GAME_WINDOW_TITLE
	ControlSend,, {space}, % GAME_WINDOW_TITLE
}




; =============================================================================
; Wiggle on killer's shoulders
; =============================================================================
WiggleOnKillersShoulders() {
	global ttip
	ttip.add("wiggle", "Wiggling...")
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
	ttip.remove("wiggle")
}


; =============================================================================
; Cancel toggleable action
; ------------------------
; Description: Cancels any action that is currently running depending on the
; 'toggle' variable.
; =============================================================================
CancelToggleableAction() {
	global toggle, ttip

	if (toggle) {
		toggle := False
		ttip.remove("gen-tap")
		ttip.remove("chat-flood")
	}
	else {
		Send, {esc}
	}	
}



#IfWinActive


class MouseButtonLockManager {
	_ttip :=
	_m1_locked := False
	_m2_locked := False


	__New(multi_tooltip) {
		this._ttip := multi_tooltip
	}


	toggleLock() {
		if (this._m1_locked or this._m2_locked) {
			this._unlock()
			return False
		}

		lButtonDown := GetKeyState("LButton", "P")
		rButtonDown := GetkeyState("RButton", "P")

		if (lButtonDown) {
			this._lockM1()
		}
		else if (rButtonDown) {
			this._lockM2()
		}

		return lButtonDown or rButtonDown
	}

	_lockM1() {
		this._ttip.add("lock-m1", "Holding M1...")
		this._m1_locked := True
	}

	_lockM2() {
		this._ttip.add("lock-m2", "Holding M2...")
		this._m2_locked := True
	}

	_unlock() {
		this._unlockM1()
		this._unlockM2()
	}

	_unlockM1() {
		if (this._m1_locked) {
			this._m1_locked := False
			this._ttip.remove("lock-m1")
		}		

		if (this._m2_locked) {
			Click,, Right,, Up
			this._m2_locked := False
			this._ttip.remove("lock-m2")			
		}
	}

	_unlockM2() {
		if (this._m1_locked) {
			Click,, Left,, Up
			this._m1_locked := False
			this._ttip.remove("lock-m1")
		}		

		if (this._m2_locked) {
			this._m2_locked := False
			this._ttip.remove("lock-m2")			
		}
	}


	notifyLeftButtonDown() {
		this._unlockM1()
		Click,, Left,, Down
	}

	notifyLeftButtonUp() {
		if (this._m1_locked) {
			return
		}
		Send, {LButton Up}
	}

	notifyRightButtonDown() {
		this._unlockM2()
		Click,, Right,, Down
	}

	notifyRightButtonUp() {
		if (this._m2_locked) {
			return
		}
		Send, {RButton Up}
	}

}


class MultiTooltip {

	_messages := {}


	add(key, message) {
		this._messages[key] := message
		this._displayAll()
	}

	removeAll() {
		this._messages := {}
		ToolTip
	}

	remove(key) {
		this._messages.Delete(key)
		this._displayAll()
	}

	_displayAll() {
		tooltip := ""

		for key, msg in this._messages {
			tooltip := tooltip msg "`n"
		}

		coords := GetScreenCoords(0.45, 0.01)
		Tooltip, %tooltip%, coords[1], coords[2]
	}
}




; ------------------------------------------------------------------------------------
; Utility functions
; ------------------------------------------------------------------------------------
GetScreenCoords(xPercent, yPercent) {
	global GAME_WINDOW_TITLE
	windowWidth := 0
	windowHeight := 0
	WinGetPos,,, windowWidth, windowHeight, % GAME_WINDOW_TITLE
	return [Round(windowWidth * xPercent), Round(windowHeight * yPercent)]
}
