# Via https://stackoverflow.com/questions/24096969/powershell-named-pipe-no-connection
# On security see: https://csandker.io/2021/01/10/Offensive-Windows-IPC-1-NamedPipes.html#
# https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea?redirectedfrom=MSDN
# Closing it: "An instance of a named pipe is always deleted when the last handle to the instance of the named pipe is closed."
# if necessary use handle.exe
# You can also close the named pipe from another process using (I dunno why this works...)
# get-childitem -path "\\.\pipe\$pipeName"

# Show all named pipes: get-childitem -path "\\.\pipe\"

#region Server
$pipeName = "PSNamedPipe"
$direction = 1
# If you set this >1 more than one server can listen.
# Set this to 255 for "unlimited"
$maxNumberOfServerInstances = 1
# https://learn.microsoft.com/en-us/dotnet/api/system.io.pipes.pipetransmissionmode?view=net-8.0
# 0: "stream of bytes". 1: "stream of messages"
$transmissionMode = 1

# Make sure not "everyone" can write to your named pipe:
# https://learn.microsoft.com/en-us/dotnet/api/system.io.pipes.pipedirection?view=net-8.0
# https://learn.microsoft.com/en-us/dotnet/api/system.io.pipes.pipeoptions?view=net-8.0
# ToDo: block network access? https://stackoverflow.com/questions/3478166/named-pipe-server-throws-unauthorizedaccessexception-when-creating-a-second-inst
# This only seems to work in powershell 7
$options = [System.IO.Pipes.PipeOptions]536870912

# Constructor
$NamedPipeServer = [System.IO.Pipes.NamedPipeServerStream]::new([string] $pipeName, [System.IO.Pipes.PipeDirection] $direction,
    [int]$maxNumberOfServerInstances, [System.IO.Pipes.PipeTransmissionMode] $transmissionMode, [System.IO.Pipes.PipeOptions] $options)

$NamedPipeServer.WaitForConnection()
$StreamReader = [System.IO.StreamReader]::New($NamedPipeServer)
while ($null -ne ($data = $StreamReader.ReadLine())) {
    "Received: $data"
}
$StreamReader.Dispose()
$NamedPipeServer.Dispose()
# Took this from PSService.ps1, supposedly forces the garbage collector to do its work.
$null = $StreamReader
$null = $NamedPipeServer
#endregion Server

