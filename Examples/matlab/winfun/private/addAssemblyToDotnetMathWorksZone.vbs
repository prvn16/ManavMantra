' Copyright 2008 The MathWorks, Inc.

' Run with cscript addAssemblyToDotnetMathWorksZone.vbs assemblyFileName, groupName
' The script will attempt to create the MathWorks_Zone in the .NET configuration if it doesn't 
' already exist and then add the strongly-named assembly file to the MathWorks_Zone, giving
' it the name groupName.
'
' An exit code of 1 indicates that an error occurred.  If this script is not called in 
' batch mode, then the error message will be echo'd.

' NB This vbs file is being used by the PCT team, so please do not move it to a new
' location without informing them.

' Force variables to be declared before use
Option Explicit

' Parse input arguments
Dim assemblyName, groupName
assemblyName = WScript.Arguments(0)
groupName = WScript.Arguments(1)

' Don't throw errors, instead handle them using handleError
On Error Resume Next

Dim caspol
Set caspol = New dotnetCodeAccessSecurityPolicy
checkForError

' Check if the subgroup already exists
If caspol.groupExists(groupName) Then
    WScript.Echo "Group " & groupName & " already exists in the .NET Code Access Security Policy."
    WScript.Quit(0)
End If

' Check that the MathWorks_Zone exists.  Create it if it doesn't.
Dim mathworksZoneName, mathworksZoneExists
mathworksZoneName = "MathWorks_Zone"
mathworksZoneExists = caspol.groupExists(mathworksZoneName)
checkForError

If Not mathworksZoneExists Then
    WScript.Echo "Creating MathWorks_Zone."
    caspol.createIntranetZone(mathworksZoneName)
    checkForError
End If

' Create the strong-named group in the MathWorks_Zone
WScript.Echo "Creating group " & groupName & "."
caspol.createFullTrustStrongNameSubgroup mathworksZoneName, assemblyName, groupName
checkForError

'----------------------------------------------------------------------
' Check if an error occurred and exit if it did.
'----------------------------------------------------------------------
Sub checkForError
    If Err.Number <> 0 Then
        exitError
    End If
End Sub


'----------------------------------------------------------------------
' Error handling function - display the message and quit with error code 1
'----------------------------------------------------------------------
Sub exitError
    WScript.Echo "Error occurred: " & Err.Description
    WScript.Quit(1)
End Sub


'----------------------------------------------------------------------
' Class for interacting with the .NET Security policy
'----------------------------------------------------------------------
Class dotnetCodeAccessSecurityPolicy

' Private properties
Private fCaspolCommand
Private fWshShell


'----------------------------------------------------------------------
' Constructor
'----------------------------------------------------------------------
Private Sub Class_Initialize
    fCaspolCommand = findCaspolCommand
    ' Create a WScript.Shell for executing system commands
    Set fWshShell = CreateObject("WScript.Shell")
End Sub


'----------------------------------------------------------------------
' Gets the full path to caspol.exe.  Starts by looking for the .NET Framework
' 2.0 version and then the .NET Framework 3.0 version.
'----------------------------------------------------------------------
Private Function findCaspolCommand
    Dim errorDescription
    Const HKEY_LOCAL_MACHINE = &H80000002
    Const GET_CASPOL_COMMAND_ERROR_NUMBER_OFFSET = 1000
    Const GET_CASPOL_COMMAND_ERROR_SOURCE = "enableNETSecurityFromNetworkDrive:getCaspolCommand"

    Dim registry, dotNetKeyName
    ' Get access to the registry
    ' See http://msdn.microsoft.com/en-us/library/aa392722(VS.85).aspx
    ' Good examples can be found at
    ' http://www.activexperts.com/activmonitor/windowsmanagement/adminscripts/registry/
    ' {impersonationLevel=impersonate} means that we will use the credentials of the user that 
    ' is running this script.
    ' \\.\root\default:StdRegProv means that we want an instance of StdRegProv (which is in the
    ' root\default namespace) for the current machine.
    Set registry=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\default:StdRegProv")
    dotNetKeyName = "SOFTWARE\Microsoft\.NETFramework"

    ' Get the .NET Install Root from the registry
    Dim dotNetInstallRootKeyName, dotNetInstallRoot
    dotNetInstallRootKeyName = "InstallRoot"
    registry.GetStringValue HKEY_LOCAL_MACHINE, dotNetKeyName, dotNetInstallRootKeyName, dotNetInstallRoot
    If IsNull(dotNetInstallRoot) Then
        errorDescription = "Failed to locate .NET Framework Install Root."
        Err.Raise vbObjectError + GET_CASPOL_COMMAND_ERROR_NUMBER_OFFSET + 1, _
            GET_CASPOL_COMMAND_ERROR_SOURCE, errorDescription
    End If

    ' Try to get version 2.0 info
    Dim dotNetPolicyVersionKeyPrefix, versionString, versionInfoNames
    dotNetPolicyVersionKeyPrefix = dotNetKeyName + "\policy\v"
    versionString = "2.0"
    registry.EnumValues HKEY_LOCAL_MACHINE, dotNetPolicyVersionKeyPrefix + versionString, versionInfoNames
    ' If we failed to get version 2, try to get version 3.0 instead
    If IsNull(versionInfoNames) Then
        versionString = "3.0"
        registry.EnumValues HKEY_LOCAL_MACHINE, dotNetPolicyVersionKeyPrefix + versionString, versionInfoNames
    ' If we failed to get version 3, try to get version 4.0 instead
        If IsNull(versionInfoNames) Then
            versionString = "4.0"
            registry.EnumValues HKEY_LOCAL_MACHINE, dotNetPolicyVersionKeyPrefix + versionString, versionInfoNames
            If IsNull(versionInfoNames) Then
                errorDescription = "Failed to locate .NET Framework install location. " & _
                "Please ensure that the .NET Framework version 2.0 or later is installed."
                Err.Raise vbObjectError + GET_CASPOL_COMMAND_ERROR_NUMBER_OFFSET + 2, _
                GET_CASPOL_COMMAND_ERROR_SOURCE, errorDescription
            End If
        End If
    End If

    ' Build up the specific version and revision string
    Dim versionAndRevisionString
    versionAndRevisionString = "v" + versionString + "." + versionInfoNames(0)

    ' Build up the full location for caspol.exe
    Dim fileSystem, fileStream, caspolExe
    Set fileSystem = CreateObject("Scripting.FileSystemObject")
    caspolExe = fileSystem.BuildPath(fileSystem.BuildPath(dotNetInstallRoot, versionAndRevisionString), "caspol.exe") 

    'Check to see if caspol.exe exists.
    If Not fileSystem.FileExists(caspolExe) Then
        errorDescription = "Could not find " & caspolExe & ". Please check your .NET Framework installation."
        Err.Raise vbObjectError + GET_CASPOL_COMMAND_ERROR_NUMBER_OFFSET + 3, _
            GET_CASPOL_COMMAND_ERROR_SOURCE, errorDescription
    End If

    findCaspolCommand = caspolExe
End Function


'----------------------------------------------------------------------
' Private Function to change the name of an existing group in the .NET 
' configuration.  Returns True if the name of the group could be changed
' (i.e. it existed).
'----------------------------------------------------------------------
Private Function changeGroupName(originalGroupName, newGroupName)
    ' Change the specified original group name to the new group name
    Dim commandString
    commandString = fCaspolCommand & " -q -cg """ & originalGroupName & """ -name """ & newGroupName & """"

    Dim caspolExec
    Set caspolExec = fWshShell.Exec(commandString)
    ' Wait for the command to finish
    Do While caspolExec.Status = 0
         WScript.Sleep 100
    Loop

    changeGroupName = (caspolExec.ExitCode = 0)
End Function


'----------------------------------------------------------------------
' Determine if the specified group exists in the .NET configuration
'----------------------------------------------------------------------
Public Function groupExists(groupName)
    ' Check to see if the groupName exists by trying to change the
    ' group to a temp name. If the exit code from this command is 0, that means
    ' the groupName exists and we will change it back to it's original
    ' name and return.
    groupExists = False
    Dim tempGroupName, canChangeName
    tempGroupName = groupName & "_test"
    canChangeName = changeGroupName(groupName, tempGroupName)
    If canChangeName Then
        'Change the group name back to the original
        changeGroupName tempGroupName, groupName
        groupExists = True
    End If
End Function


'----------------------------------------------------------------------
' Create an Intranet zone with permission set=LocalIntranet and the specified zone name
'----------------------------------------------------------------------
Public Function createIntranetZone(zoneName)
    Const CREATE_INTRANET_ZONE_ERROR_NUMBER_OFFSET = 1100
    Const CREATE_INTRANET_ZONE_ERROR_SOURCE = "enableNETSecurityFromNetworkDrive:createIntranetZone"

    ' create a Local Intranet group with name MathWorks_Zone under machine->Code Groups->All_Code
    Dim intranetZoneString, commandString
    intranetZoneString = "Intranet LocalIntranet"
    commandString = fCaspolCommand & " -q -m -ag 1. -zone " & intranetZoneString & " -name """ & zoneName & """"

    ' NB If MathWorks_Zone is going to be allcode membership with Nothing permission set then the 
    ' caspol command would look something like this:
    'commandString = fCaspolCommand & " -q -m -ag 1. -allcode Nothing -name """ & groupName & """"

    Dim caspolExec
    Set caspolExec = fWshShell.Exec(commandString)
    ' Wait for the command to finish
    Do While caspolExec.Status = 0
         WScript.Sleep 100
    Loop

    If caspolExec.ExitCode <> 0 Then
        Dim caspolStdout, errorDescription
        caspolStdout = caspolExec.StdOut.ReadAll
        errorDescription = "Failed to create " & zoneName & "." & vbCrLf & "Command: " & commandString & _
            vbCrLf & "Message: " & caspolStdout
        Err.Raise vbObjectError + CREATE_INTRANET_ZONE_ERROR_NUMBER_OFFSET, _
            CREATE_INTRANET_ZONE_ERROR_SOURCE, errorDescription
    End If 
End Function


'----------------------------------------------------------------------
' Create a subgroup for the specified strong-named assembly in the specified
' parent zone.  
'----------------------------------------------------------------------
Public Function createFullTrustStrongNameSubgroup(parentZoneName, strongFilename, subgroupName)
    Const CREATE_STRONG_NAME_SUBGROUP_ERROR_NUMBER_OFFSET = 1200
    Const CREATE_STRONG_NAME_SUBGROUP_ERROR_SOURCE = "enableNETSecurityFromNetworkDrive:createStrongNameSubgroup"

    Dim commandString
    commandString = fCaspolCommand & " -q -m -ag " & parentZoneName & " -strong -file """ & strongFilename & _
        """ -noname -noversion FullTrust -name """ & subgroupName & """"

    Dim caspolExec
    Set caspolExec = fWshShell.Exec(commandString)
    ' Wait for the command to finish
    Do While caspolExec.Status = 0
         WScript.Sleep 100
    Loop

    If caspolExec.ExitCode <> 0 Then
        Dim caspolStdout, errorDescription
        caspolStdout = caspolExec.StdOut.ReadAll
        errorDescription = "Failed to create subgroup " & subgroupName & " in zone " & parentZoneName & vbCrLf &_
            "Command: " & commandString & vbCrLf & "Message: " & caspolStdout
        Err.Raise vbObjectError + CREATE_STRONG_NAME_SUBGROUP_ERROR_NUMBER_OFFSET, _
            CREATE_STRONG_NAME_SUBGROUP_ERROR_SOURCE, errorDescription
    End If 
End Function

End Class

