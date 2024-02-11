# Via https://stackoverflow.com/questions/24096969/powershell-named-pipe-no-connection
# On security see: https://csandker.io/2021/01/10/Offensive-Windows-IPC-1-NamedPipes.html#
# https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createnamedpipea?redirectedfrom=MSDN
# Closing it: "An instance of a named pipe is always deleted when the last handle to the instance of the named pipe is closed."
# if necessary use handle.exe


$pipeName = "PSNamedPipe"
$direction = 2
# We only want to connect to pipes the same user created:
# This only seems to work in powershell 7
$options = [System.IO.Pipes.PipeOptions]536870912

#region Client
# System.IO.Pipes.NamedPipeClientStream new(string serverName, string pipeName, System.IO.Pipes.PipeDirection direction, System.IO.Pipes.PipeOptions options, System.Security.Principal.TokenImpersonationLevelimpersonationLevel)
# https://learn.microsoft.com/en-us/dotnet/api/system.io.pipes.namedpipeclientstream.-ctor?view=net-8.0
# System.Security.Principal.TokenImpersonationLevel
# Anonymous 	1 	The server process cannot obtain identification information about the client, and it cannot impersonate the client.
# Make sure the server can't impersonate the client (client side).
$serverName = "."
$impersonationLevel = [System.Security.Principal.TokenImpersonationLevel]1
$NamedPipeClient = [System.IO.Pipes.NamedPipeClientStream]::New([string] $serverName, [string] $pipeName, [System.IO.Pipes.PipeDirection] $direction, [System.IO.Pipes.PipeOptions] $options, [System.Security.Principal.TokenImpersonationLevel] $impersonationLevel)
$NamedPipeClient.Connect()
$StreamWriter = [System.IO.StreamWriter]::New($NamedPipeClient)
if ($StreamWriter) {
    $StreamWriter.AutoFlush = $true
    $StreamWriter.WriteLine("This is a test message from process $PID")
    $StreamWriter.Dispose()
    $null = $StreamWriter
}
#endregion Client
