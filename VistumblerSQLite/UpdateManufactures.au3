#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;License Information------------------------------------
;Copyright (C) 2009 Andrew Calcutt
;This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; Version 2 of the License.
;This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
;You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;--------------------------------------------------------
;AutoIt Version: v3.3.6.1
$Script_Author = 'Andrew Calcutt'
$Script_Name = 'Update Manufactures'
$Script_Website = 'http://www.Vistumbler.net'
$Script_Function = 'Creates Manufacturer.SDB using phils manufmac.exe'
$version = 'v1'
$origional_date = '2010/06/02'
;--------------------------------------------------------
#include <SQLite.au3>
#include "UDFs\FileInUse.au3"

Dim $TmpDir = @ScriptDir & "\temp\"
Dim $TmpManuDB_OBJ
Dim $TmpManuDB = @ScriptDir & "\Settings\" & "ManufacturersTmp.SDB"
Dim $ManuDB = @ScriptDir & "\Settings\" & "Manufacturers.SDB"
Dim $ManufMacEXE = @ScriptDir & "\manufmac.exe" ;Phils PHP script to create manufactures.ini based on ieee.org oui.txt
Dim $ManuINI = @ScriptDir & "\manufactures.ini" ;Vistumbler Manufacturer ini file (generated by manufmac.exe)
Dim $ManuINCPHP = @ScriptDir & "\manufactures.inc.php" ;WiFiDB Manufacturer file (generated by manufmac.exe)

;Cleanup Files
FileDelete($TmpManuDB)
FileDelete($ManuINI)
FileDelete($ManuINCPHP)

;Run PHP script to get manuactures
RunWait($ManufMacEXE)

;Read Geneated manufactures.ini from manufmac.exe
If FileExists($ManuINI) Then
	FileDelete($TmpManuDB)
	_SQLite_Startup()
	$TmpManuDBhndl = _SQLite_Open($TmpManuDB, $SQLITE_OPEN_READWRITE + $SQLITE_OPEN_CREATE, $SQLITE_ENCODING_UTF16)
	_SQLite_Exec($TmpManuDBhndl, "CREATE TABLE Manufacturers (BSSID,Manufacturer)")
	_SQLite_Exec($TmpManuDBhndl, "pragma synchronous=0");Speed vs Data security. Speed Wins for now.
	ProgressOn ( "Creating Manufacturers.SDB", "Adding Manufacturer" , "" , -1 , -1 , 18)
	_ReadManucaturerIniToDB($ManuINI, $TmpManuDB, $TmpManuDB_OBJ, "Manufacturers")
	ProgressOff()
	_SQLite_Close($TmpManuDBhndl)
	$SDBoverwrite = MsgBox(4, "Done", "A new Manufactures.SDB has been created. Would you like to overwrite the old vistumbler Manufactures.SDB?")
	If $SDBoverwrite = 6 Then
		While 1
			If _FileInUse($ManuDB) = 1 Then
				$updatemsg = MsgBox(1, 'Error', 'The vistumbler Manufacturers.SDB seems to be in use. Verify that vistumbler is closed and click "OK" to continue')
				If $updatemsg = 2 Then ExitLoop
			EndIf
			$fms = FileMove($TmpManuDB, $ManuDB, 1)
			If $fms = 1 Then
				$updatemsg = MsgBox(4, "Done", "Done. Would you like to load vistumbler?")
				If $updatemsg = 6 Then Run(@ScriptDir & '\Vistumbler.exe')
				ExitLoop
			Else
				$updatemsg = MsgBox(4, "Error", "An error occured copying Manufacturers.SDB. Would you like to try again?")
				If $updatemsg = 7 Then ExitLoop
			EndIf
		Wend
	EndIf
EndIf

;Cleanup Files
FileDelete($TmpManuDB)
FileDelete($ManuINI)
FileDelete($ManuINCPHP)

Func _ReadManucaturerIniToDB($ini, ByRef $DB, ByRef $DBOBJ, $DBTABLE)
	;Get Total number of lines
	$inifile = FileOpen($ini, 0)
	$totallines = 0
	While 1
		FileReadLine($inifile)
		If @error = -1 Then ExitLoop
		$totallines += 1
	WEnd
	$sectionstartline = 3; First line of the section in the ini
	$startvalue = 1 ;Start number for GUI
	$totallines = ($totallines - $sectionstartline) + $startvalue
	_SQLite_Exec($TmpManuDBhndl, "BEGIN;")
	While 1
		$linein = FileReadLine($inifile, $sectionstartline)
		If @error = -1 Then ExitLoop
		;ConsoleWrite($startvalue & '/' & $totallines & @CRLF)
		If StringInStr($linein, '=') Then
			$infosplit = StringSplit($linein, '=')
			$query = "INSERT INTO Manufacturers(BSSID,Manufacturer) VALUES ('" & $infosplit[1] & "','" & StringReplace($infosplit[2], "\'", "''") & "');"
			_SQLite_Exec($TmpManuDBhndl, $query)
		EndIf
		$UpdatePercentDone = ($startvalue / $totallines) * 100
		ProgressSet($UpdatePercentDone, "", "Adding Manufacturer: " & $startvalue & '/' & $totallines)
		$sectionstartline += 1
		$startvalue += 1
	WEnd
	_SQLite_Exec($TmpManuDBhndl, "COMMIT;")
	FileClose($startvalue)
EndFunc
