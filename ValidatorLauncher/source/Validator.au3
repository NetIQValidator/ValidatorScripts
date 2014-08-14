; Launcher for NetIQ Validator
;
; Copyright 2013 Lothar Haeger
;
; This Source Code Form is subject to the terms of the Mozilla Public
; License, v. 2.0. If a copy of the MPL was not distributed with this
; file, You can obtain one at http://mozilla.org/MPL/2.0/.

#include <Process.au3>
#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

;preferences
$product = "Launcher for NetIQ Validator"
$version = "v0.9.1, 2014-08-14"
$author = "Lothar Haeger, lothar.haeger@is4it.de"

$serv_title = "Validator for Identity Manager Service"
$serv_window = $serv_title
$propsfile = 'config\validator.properties'
$licfile = 'config\license.dat'
$tests_default = "tests"
$base_url = StringRegExpReplace(PropsRead($propsfile, "MAIN_URL"),"/validator$","")

If StringRegExp($base_url, ".*/validator$") = 1 Then
	$validator_version = 1.3
	$base_url = StringRegExpReplace($base_url,"/validator$","")
	$css_url = $base_url & "/validator/css/validatorStyle.css"
	$classpath = "lib/*;lib/ext/*"
Else
	$validator_version = 1.2
	$css_url = $base_url & "/validator/css/blitzer/validator.css"
	$classpath = "lib/*;lib/ext/*;lib/enc/*;lib/jldap/*;lib/json/*;lib/junit/*;lib/mysql/*;lib/mssql/*;lib/rest/*;lib/ssl/*;lib/oracle10g/*;lib/jasperreport/*;lib/userapp/*"
EndIf

$inifile = StringRegExpReplace(@ScriptFullPath,"^(.*)\..*?$","$1.ini")
$browser = IniRead($inifile,"Settings", "Browser", "")
$license = IniRead($inifile,"Settings", "License", "")
$start_client = IniRead($inifile,"Settings", "Start_Client", "")
$start_prefs  = IniRead($inifile,"Settings", "Start_Prefs", "")
$hide_console = IniRead($inifile,"Settings", "Hide_Console", "")
$debug = IniRead($inifile,"Settings", "Debug", "")

;functions
Func PropsRead($file, $item)
	$properties = FileRead($file)
	$value = StringReplace(StringStripCR($properties),@LF,"|")
	$value = StringRegExpReplace($value,".*" & $item & "=([^|]*)|.*","$1")
	$value = StringRegExpReplace($value, "\\([\\:])", "$1")
	Return $value
EndFunc

Func PropsWrite($file, $item, $value)
	$properties = FileRead($file)
	$esc_value = StringReplace(StringReplace($value,"\","\\\\"),":","\\:")
	$new_properties = StringRegExpReplace($properties,$item & "=.*", $item & "=" & $esc_value & @CR)
	$filehandle = FileOpen($file,2)
	FileWrite($filehandle, $new_properties)
	FileClose($filehandle)
EndFunc

Func ProcessGetHandle($pid, $winTitle = "", $timeout = 30)     
	For $retry = 1 To $timeout
		$wins = WinList($winTitle)         
		For $i = 1 To UBound($wins)-1             
			If (WinGetProcess($wins[$i][1]) == $pid) Then Return $wins[$i][1]       
		Next
		Sleep(1000)
	Next
EndFunc

Func start_server()
	TrayTip("", "Starting Validator service...", 1)

	; check if the validator service is already running
	$css_size = InetGetSize($css_url,1)
	If Not $css_size = 0 Then
		MsgBox(48,$product,'Seems like the Validator service is already running. Please stop it and try again')
		Exit
	EndIf

	$options = ""
	If $debug = "true" Then $options = "debug"
	If FileExists($license) Then FileCopy($license, @ScriptDir & '\' & $licfile, 1)
	$serv_pid = Run('jre\bin\java.exe -cp ' & $classpath & ' -Dsun.net.httpserver.idleInterval="3600" com.novell.nccd.validator.RESTServer ' & $options, "", @SW_HIDE)
	$serv_window = ProcessGetHandle($serv_pid, @ScriptDir & "\jre\bin\java.exe", 5)
	WinSetTitle($serv_window, "", $serv_title)
	If $hide_console = "false" Then	
		TrayTip("", "", 0)
		WinSetState($serv_window, "", @SW_RESTORE)
	EndIf
	Sleep(1000)
	If Not WinExists($serv_window) Then
		$logfile = @ScriptDir & '\log\validator.log'
		$errlog = FileRead($logfile, 200)
		MsgBox(48,$product,'An error occured trying to start the validator server task. Please see full ' & $logfile & ' for details:' & @LF & @LF & $errlog & ' ...')
	EndIf
	TrayTip("", "", 0)
EndFunc

Func stop_server()
	If WinExists($serv_window) Then 
		If $hide_console <> "false" Then
			TrayTip("", "Stopping Validator service...", 1)
			WinSetTrans($serv_window,"",0)
		EndIf
		WinActivate($serv_window)
		WinWaitActive($serv_window,"",30)
		Send("{ENTER}")
		If $hide_console <> "false" Then 
			WinSetState($serv_window,"",@SW_HIDE)
			WinSetTrans($serv_window,"",100)
		EndIf
		WinWaitClose($serv_window,"",30)
	EndIf
	If WinExists($serv_window) Then WinClose($serv_window)
	TrayTip("", "", 0)
EndFunc

Func start_client()
	$url = StringRegExpReplace($base_url,"\d\.\d\.\d\.\d","localhost") & "/validator"
	If FileExists($browser) Then
		ShellExecute($browser, $url)	
	Else
		ShellExecute($url)
	EndIf
EndFunc

Func start_runner()
	$url = StringRegExpReplace($base_url,"\d\.\d\.\d\.\d","localhost") & "/runner"
	If FileExists($browser) Then
		ShellExecute($browser, $url)	
	Else
		ShellExecute($url)
	EndIf
EndFunc

Func prefs_dialog()
	$tests = PropsRead($propsfile, "TESTS_LOC")
	$new_tests = $tests
	$restart = 0
	;build prefs dialog
	$prefs_window = GUICreate("Validator Preferences", 500, 330, -1, -1, -1,-1)
	$test_chk = GUICtrlCreateCheckbox("Use default tests folder", 30, 10)
	$test_txt = GUICtrlCreateInput($tests, 45, 35, 400, 20)
	$test_sel = GUICtrlCreateButton("...", 445, 35, 20, 20)
	$lic_chk  = GUICtrlCreateCheckbox("Use default license file", 30, 70)
	$lic_txt  = GUICtrlCreateInput($license, 45, 95, 400, 20)
	$lic_sel  = GUICtrlCreateButton("...", 445, 95, 20, 20)
	$check    = GUICtrlCreateCheckbox("Use system default browser", 30, 130)
	$input    = GUICtrlCreateInput($browser, 45, 155, 400, 20)
	$select   = GUICtrlCreateButton("...", 445, 155, 20, 20)
	$c_start  = GUICtrlCreateCheckbox("Open Validator client on start", 30, 190)
	$s_show   = GUICtrlCreateCheckbox("Show Validator service console", 30, 220)
	$s_debug  = GUICtrlCreateCheckbox("Enable Debug mode", 30, 250)
	$s_prefs  = GUICtrlCreateCheckbox("Show Preferences on startup", 30, 280)
	$b_close  = GUICtrlCreateButton("Apply", 390, 280, 90, 30)
	If Not WinExists($serv_title) Then GUICtrlSetData($b_close, "Start")
	;initialize with current values
	If $tests = $tests_default Then 
		GUICtrlSetState($test_chk, $GUI_CHECKED)
		GUICtrlSetState($test_sel, $GUI_DISABLE)
		GUICtrlSetState($test_txt, $GUI_DISABLE)
	EndIf
	If $browser = "" Then 
		GUICtrlSetState($check, $GUI_CHECKED)
		GUICtrlSetState($select, $GUI_DISABLE)
		GUICtrlSetState($input, $GUI_DISABLE)
	EndIf
	If $license = $licfile Or $license = "" Then 
		GUICtrlSetState($lic_chk, $GUI_CHECKED)
		GUICtrlSetState($lic_sel, $GUI_DISABLE)
		GUICtrlSetState($lic_txt, $GUI_DISABLE)
		GUICtrlSetData ($lic_txt, $licfile)
	EndIf
	If $start_client <> "false" Then GUICtrlSetState($c_start, $GUI_CHECKED)
	If $hide_console <> "true" Then GUICtrlSetState($s_show, $GUI_CHECKED)
	If $debug = "true" Then	GUICtrlSetState($s_debug, $GUI_CHECKED)
	If $start_prefs <> "false" Then GUICtrlSetState($s_prefs, $GUI_CHECKED)
	GUISetState(@SW_SHOW)
	;enter message loop
	While 1
		$msg2 = GUIGetMsg(1)
		Select
			Case $msg2[0] = $check
				If GUICtrlRead($check) = $GUI_CHECKED Then
					$browser = ""
					GUICtrlSetState($input, $GUI_DISABLE)
					GUICtrlSetState($select, $GUI_DISABLE)
				Else
					GUICtrlSetState($input, $GUI_ENABLE)
					GUICtrlSetState($select, $GUI_ENABLE)
				EndIf
			Case $msg2[0] = $select
				$browser = GUICtrlRead($input)
				If StringLen($browser) > 0 Then
					$bpath = StringRegExpReplace($browser,"^(.*)\\.*$","$1")
				Else
					$bpath = @ProgramFilesDir
				EndIf
				$new_browser = FileOpenDialog("Select Browser...", $bpath & "\", "Executables (*.exe)", 1 + 4)
				If StringLen($new_browser) > 0 And FileExists($new_browser) Then 
					$browser = $new_browser
					GUICtrlSetData ($input, $browser)
				EndIf
			Case $msg2[0] = $test_chk
				If GUICtrlRead($test_chk) = $GUI_CHECKED Then
					$new_tests = $tests_default
					GUICtrlSetData($test_txt, $tests_default)
					GUICtrlSetState($test_sel, $GUI_DISABLE)
					GUICtrlSetState($test_txt, $GUI_DISABLE)
				Else
					GUICtrlSetState($test_sel, $GUI_ENABLE)
					GUICtrlSetState($test_txt, $GUI_ENABLE)
				EndIf
				$restart = 1
			Case $msg2[0] = $test_sel
				$init_dir = $tests
				If Not StringRegExp($init_dir, ":") Then $init_dir = @ScriptDir & "\" & $init_dir
				$new_tests = FileSelectFolder("Select Validator Tests Folder...", "", 1+2+4, $init_dir)
				If StringLen($new_tests) > 0 And FileExists($new_tests) Then 
					GUICtrlSetData($test_txt, $new_tests)
					$restart = 1
				Else
					$new_tests = $tests
				EndIf
			Case $msg2[0] = $lic_chk
				If GUICtrlRead($lic_chk) = $GUI_CHECKED Then
					$license = $licfile
					GUICtrlSetData ($lic_txt, $licfile)
					GUICtrlSetState($lic_txt, $GUI_DISABLE)
					GUICtrlSetState($lic_sel, $GUI_DISABLE)
				Else
					GUICtrlSetState($lic_txt, $GUI_ENABLE)
					GUICtrlSetState($lic_sel, $GUI_ENABLE)
				EndIf
				$restart = 1
			Case $msg2[0] = $lic_sel
				$license = GUICtrlRead($lic_txt)
				If StringLen($license) > 0 Then
					$lpath = StringRegExpReplace($license,"^(.*)\\.*$","$1")
				Else
					$lpath = @ScriptDir
				EndIf
				$new_license = FileOpenDialog("Select License File...", $lpath & "\", "Validator Licenses (*.dat)", 1 + 4)
				If StringLen($new_license) > 0 And FileExists($new_license) Then 
					$license = $new_license
					GUICtrlSetData ($lic_txt, $license)
					$restart = 1
				EndIf
			Case $msg2[0] = $c_start
				If GUICtrlRead($c_start) = $GUI_CHECKED Then
					$start_client = "true"
				Else
					$start_client = "false"
				EndIf
			Case $msg2[0] = $s_show
				If GUICtrlRead($s_show) = $GUI_CHECKED Then
					$hide_console = "false"
					WinSetState($serv_window,"",@SW_SHOW)
					WinWaitActive($serv_window,"",3)
					WinActivate($prefs_window)
				Else
					$hide_console = "true"
					If WinExists($serv_window) Then WinSetState($serv_window,"",@SW_HIDE)
					WinSetState($prefs_window,"",@SW_SHOW)
					WinActivate($prefs_window)
				EndIf
			Case $msg2[0] = $s_debug
				If GUICtrlRead($s_debug) = $GUI_CHECKED Then
					$debug = "true"
				Else
					$debug = "false"
				EndIf
				$restart = 1
			Case $msg2[0] = $s_prefs
				If GUICtrlRead($s_prefs) = $GUI_CHECKED Then
					$start_prefs = "true"
				Else
					$start_prefs = "false"
				EndIf
			Case ( $msg2[0] = $GUI_EVENT_CLOSE And $msg2[1] = $prefs_window ) or $msg2[0] = $b_close
				If FileExists(GuiCtrlRead($test_txt)) Then
					If $tests <> GuiCtrlRead($test_txt) Then
						$restart = 1
						$new_tests = GuiCtrlRead($test_txt)
					EndIf
					If FileExists(GuiCtrlRead($lic_txt)) Then
						If $license <> GuiCtrlRead($lic_txt) Then 
							$restart = 1	
							$license = GuiCtrlRead($lic_txt)
						EndIf
						If GuiCtrlRead($input) == "" OR FileExists(GuiCtrlRead($input)) Then
							$browser = GuiCtrlRead($input)
							ExitLoop
						Else
							Msgbox(262144 + 16 + 0, "Error", "The entered Browser does not exist!")
						EndIf
					Else
						Msgbox(262144 + 16 + 0, "Error", "The entered License file does not exist!")
					EndIf
				Else
					Msgbox(262144 + 16 + 0, "Error", "The entered Tests folder does not exist!")
				EndIf
		EndSelect
	WEnd 
	IniWrite($inifile, "Settings","Browser", $browser)
	IniWrite($inifile, "Settings","License", $license)
	IniWrite($inifile, "Settings","Start_Client", $start_client)
	IniWrite($inifile, "Settings","Hide_Console", $hide_console)
	IniWrite($inifile, "Settings","Debug", $debug)
	IniWrite($inifile, "Settings","Start_Prefs", $start_prefs)
	If $tests <> $new_tests Then PropsWrite($propsfile, "TESTS_LOC", $new_tests)
	GuiDelete()
	Return $restart
EndFunc

; main
; check if we are running from the validator install path
If Not FileExists('lib\validator.jar') Then
	MsgBox(48,$product,'Seems like you are running from outside of a Validator installation. Please copy the executable into the Validator install directory and try again.')
	Exit
EndIf

; Make sure to run only one instance at a time
If StringRegExp(@ScriptName,".*exe") Then
	$list = ProcessList(@ScriptName)
	If UBound($list) > 2 Then
		MsgBox(48,$product,@ScriptFullPath & ' is already running. Please use the tray menu to start a Validator client or close the program.')
		Exit
	EndIf
EndIf

;build tray menu
Opt("TrayMenuMode",1+2)
$runvalitem	= TrayCreateItem("Open Validator")
$runrunitem	= TrayCreateItem("Open Runner")
$consitem	= TrayCreateItem("Start Service")
TrayCreateItem("")
$prefsitem	= TrayCreateItem("Preferences")
$aboutitem	= TrayCreateItem("About")
TrayCreateItem("")
$exititem	= TrayCreateItem("Exit")
TrayItemSetState($runvalitem,$TRAY_DEFAULT)
TraySetToolTip($product)
TraySetState()

;show prefs dialog
If $start_prefs <> "false" Then
	prefs_dialog()
EndIf

;start validator
start_server()
If WinExists($serv_window) And $start_client <> "false" Then start_client()	

;enter message loop
While 1
	$msg = TrayGetMsg()
	If $msg <> 0 Then
		If WinExists($serv_window,"") Then
			TrayItemSetState($runvalitem,$TRAY_ENABLE)
			TrayItemSetState($runrunitem,$TRAY_ENABLE)
			$s_state= WinGetState($serv_window,"")
			If BitAND($s_state, 2) Then
				TrayItemSetText($consitem,"Hide Console")
			Else
				TrayItemSetText($consitem,"Show Console")
			EndIf
		Else
			TrayItemSetState($runvalitem,$TRAY_DISABLE)
			TrayItemSetState($runrunitem,$TRAY_DISABLE)
			TrayItemSetText($consitem,"Start Service")
		EndIf
	EndIf
	Select
		Case $msg = $runvalitem
			start_client()
		Case $msg = $runrunitem
			start_runner()
		Case $msg = $consitem
			If TrayItemGetText($consitem) = "Show Console" Then
				WinSetState($serv_window,"",@SW_SHOW)
				WinSetState($serv_window,"",@SW_RESTORE)
			ElseIf TrayItemGetText($consitem) = "Hide Console" Then
				WinSetState($serv_window,"",@SW_HIDE)
			Else
				start_server()
			EndIf
		Case $msg = $prefsitem
			$restart = prefs_dialog()
			If $restart = 1 And Msgbox(262144 + 256 + 4, "Validator Preferences", "The Validator service has to be restarted to activate any changed preferences." & @LF & "Please make sure to save any open test suite to avoid loosing data." & @LF & @LF & "Do you want to restart the service now?") = 6 Then
				stop_server()
				start_server()
			EndIf
		Case $msg = $aboutitem
			Msgbox(64, "About", $product & ", "& $version & Chr(10) & "© " & $author)
		Case $msg = $exititem
			ExitLoop
	EndSelect
WEnd

stop_server()

Exit

