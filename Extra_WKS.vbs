'==========================================================================
'
' NOME  : Extra_WKS.vbs
' AUTOR : Proteus Security Systems
' FUNçÃO: Realiza as correções que não são possíveis via template
'
'==========================================================================

On Error Resume Next


Dim Admname
Dim string
Dim wshShell
Dim language

Set wshShell = WScript.CreateObject("WScript.shell")

'=============================================================================
'Descobre o ADM Local
'=============================================================================

pcname = "."

Set objWMIService = GetObject("winmgmts:\\" & pcname & "\root\cimv2")

Set colOSes = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")

For Each objOS in colOSes
 'Wscript.Echo "Computer Name: " & objOS.CSName
  pcname = objOS.CSName
Next


strComputer = pcname

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colAccounts = objWMIService.ExecQuery _
    ("Select * From Win32_UserAccount Where Domain = '" & strComputer & "'")

For Each objAccount in colAccounts
    If Left (objAccount.SID, 6) = "S-1-5-" and Right(objAccount.SID, 4) = "-500" Then
       'Wscript.Echo objAccount.Name
	Admname = objAccount.Name
    End If
Next

'=============================================================================
'Renomea a conta do ADM Local
'=============================================================================
string = ""
string = "cusrmgr -u "&Admname&" -r Definir -c " & chr(34) & chr(34)
'WScript.Echo string
return = wshShell.run (string, 6, true)
'WScript.Echo return


'=============================================================================
'Configura lockout para o Administrator
'=============================================================================
wshShell.run "passprop.exe /adminlockout",0


'=============================================================================
'Cria Fake Administrator
'=============================================================================
language = wshshell.regread ("HKLM\SYSTEM\CurrentControlSet\Control\Nls\Language\InstallLanguage")

if language = 0409 then
	wshShell.run "net user Administrator 1q2w3e!Q@W#E@)m /add /y /active:no",0
	WScript.Sleep(1000)
	wshShell.run "cusrmgr -u Administrator -f """" -c ""Built-in account for administering the computer/domain"" -dlg Users +s AccountDisabled",0
end if
if language = 0416 then
	wshShell.run "net user Administrador 1q2w3e!Q@W#E@)m /add /y /active:no",0
	WScript.Sleep(1000)
	wshShell.run "cusrmgr -u Administrador -f """" -c ""Conta interna para administração do computador/domínio"" -dlg Users +s AccountDisabled",0
end if


'=============================================================================
'Remove subsistemas POSIX e OS/2
'=============================================================================
wshshell.regdelete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Subsystems\Posix"
wshshell.regdelete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Subsystems\Os2"
wshshell.regdelete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Os2LibPath"
Wshshell.RegDelete "HKLM\SOFTWARE\Microsoft\OS/2 Subsystem for NT\1.0\config.sys\"
Wshshell.RegDelete "HKLM\SOFTWARE\Microsoft\OS/2 Subsystem for NT\1.0\os2.ini\"
Wshshell.RegDelete "HKLM\SOFTWARE\Microsoft\OS/2 Subsystem for NT\1.0\"
Wshshell.RegDelete "HKLM\SOFTWARE\Microsoft\OS/2 Subsystem for NT\"

'WScript.Echo "Fim do Script!!!"