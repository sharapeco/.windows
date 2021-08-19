;;; Win + [0-9] as Numpad [0-9]
#0::Numpad0
#1::Numpad1
#2::Numpad2
#3::Numpad3
#4::Numpad4
#5::Numpad5
#6::Numpad6
#7::Numpad7
#8::Numpad8
#9::Numpad9

;;; Switcheroo
#IfWinActive ahk_exe switcheroo.exe
	!j::
		Send {Down}
		Return
	!k::
		Send {Up}
		Return
#IfWinActive

;;; FreeCommander XE
#IfWinActive ahk_class FreeCommanderXE.SingleInst.1
	^f::
		Send {Right}
		Return
	^b::
		Send {Left}
		Return
	^n::
		Send {Down}
		Return
	^p::
		Send {Up}
		Return
	^a::
		Send {Home}
		Return
	^e::
		Send {End}
		Return
	^d::
		Send {Delete}
		Return
	^h::
		Send {Backspace}
		Return
	^i::
		Send {Tab}
		Return
	^g::
		Send {Esc}
		Return
#IfWinActive

;;; Windows Terminal
;;; PowerShell + PSReadline で無変換キーを押したときに "@" が入力されないようにする
#IfWinActive ahk_exe WindowsTerminal.exe
	if IME_GET() {
		; 無変換
		vk1D::
			if IME_GET() {
				IME_SET(0)
			}
			return
	}
#IfWinActive

;-----------------------------------------------------------
; IMEの状態の取得
;   WinTitle="A"    対象Window
;   戻り値          1:ON / 0:OFF
;-----------------------------------------------------------
IME_GET(WinTitle="A")  {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
          ,  Int, 0)      ;lParam  : 0
}

;-----------------------------------------------------------
; IMEの状態をセット
;   SetSts          1:ON / 0:OFF
;   WinTitle="A"    対象Window
;   戻り値          0:成功 / 0以外:失敗
;-----------------------------------------------------------
IME_SET(SetSts, WinTitle="A")    {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x006   ;wParam  : IMC_SETOPENSTATUS
          ,  Int, SetSts) ;lParam  : 0 or 1
}
