# Author zhaouv@github
# modified from https://www.powershellgallery.com/packages/SysAdminsFriends/0.0.1/Content/functions%5CStart-WebServer.ps1


function Start-Webserver
{
    Param([STRING]$BINDING = 'http://localhost:8080/', [STRING]$BASEDIR = "")

    # No adminstrative permissions are required for a binding to "localhost"
    # $BINDING = 'http://localhost:8080/'
    # Adminstrative permissions are required for a binding to network names or addresses.
    # + takes all requests to the port regardless of name or ip, * only requests that no other listener answers:
    # $BINDING = 'http://+:8080/'

    function showdir {
        Param([STRING]$ROOTDIR = ".", [STRING]$DISPLAYDIR = ".")
        $ret = ""
        if (Test-Path $ROOTDIR -PathType Container)
        { # physical path is a directory
            $NAMES = Get-ChildItem -Path $ROOTDIR | Sort-Object -Property @{ Expression = 'LastWriteTime'; Descending = $true }, @{ Expression = 'Name'; Ascending = $true }
            $DIRSTR = ""
            $FILESTR = ""
            $href = (Join-Path $DISPLAYDIR -ChildPath "..") -replace "\\", "/"
            $DIRSTR += "<tr><td><a href=`"$($href)/`">../</a></td><td>-</td><td>-</td></tr>"
            Foreach ($NAME in $NAMES) {    
                # Write-Host $NAME.name
                $href = (Join-Path $DISPLAYDIR -ChildPath $NAME.name) -replace "\\", "/"
                if ($NAME.mode -eq 'd-----') {
                    $DIRSTR += "<tr><td><a href=`"$($href)/`">$($NAME.name)/</a></td><td>-</td><td>$($NAME.LastWriteTime)</td></tr>"
                } else {
                    $FILESTR += "<tr><td><a href=`"$($href)`">$($NAME.name)</a></td><td>$($NAME.length)</td><td>$($NAME.LastWriteTime)</td></tr>"
                }
            }
            $ret = '<table><tr><th>path</th><th>size</th><th>date</th></tr>' + $DIRSTR + $FILESTR + '</table>'
        }
        else
        { # no directory, check for file
            $ret = 'not dir'
        }
        $ret
    }

    if ($BASEDIR -eq "")
    {    # retrieve script path as base path for static content
        if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript")
        { $BASEDIR = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition }
        else # compiled with PS2EXE:
        { $BASEDIR = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0]) }
    }
    # convert to absolute path
    $BASEDIR = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($BASEDIR)

    # MIME hash table for static content
    $MIMEHASH = @{

        ".html"="text/html"
        ".htm"="text/html"
        ".shtml"="text/html"
        ".css"="text/css"
        ".xml"="text/xml"
        ".gif"="image/gif"
        ".jpeg"="image/jpeg"
        ".jpg"="image/jpeg"
        ".js"="application/javascript"
        ".atom"="application/atom+xml"
        ".rss"="application/rss+xml"

        ".mml"="text/mathml"
        ".txt"="text/plain"
        ".jad"="text/vnd.sun.j2me.app-descriptor"
        ".wml"="text/vnd.wap.wml"
        ".htc"="text/x-component"

        ".png"="image/png"
        ".tif"="image/tiff"
        ".tiff"="image/tiff"
        ".wbmp"="image/vnd.wap.wbmp"
        ".ico"="image/x-icon"
        ".jng"="image/x-jng"
        ".bmp"="image/x-ms-bmp"
        ".svg"="image/svg+xml"
        ".svgz"="image/svg+xml"
        ".webp"="image/webp"

        ".woff"="application/font-woff"
        ".jar"="application/java-archive"
        ".war"="application/java-archive"
        ".ear"="application/java-archive"
        ".json"="application/json"
        ".hqx"="application/mac-binhex40"
        ".doc"="application/msword"
        ".pdf"="application/pdf"
        ".ps"="application/postscript"
        ".eps"="application/postscript"
        ".ai"="application/postscript"
        ".rtf"="application/rtf"
        ".m3u8"="application/vnd.apple.mpegurl"
        ".xls"="application/vnd.ms-excel"
        ".eot"="application/vnd.ms-fontobject"
        ".ppt"="application/vnd.ms-powerpoint"
        ".wmlc"="application/vnd.wap.wmlc"
        ".kml"="application/vnd.google-earth.kml+xml"
        ".kmz"="application/vnd.google-earth.kmz"
        ".7z"="application/x-7z-compressed"
        ".cco"="application/x-cocoa"
        ".jardiff"="application/x-java-archive-diff"
        ".jnlp"="application/x-java-jnlp-file"
        ".run"="application/x-makeself"
        ".pl"="application/x-perl"
        ".pm"="application/x-perl"
        ".prc"="application/x-pilot"
        ".pdb"="application/x-pilot"
        ".rar"="application/x-rar-compressed"
        ".rpm"="application/x-redhat-package-manager"
        ".sea"="application/x-sea"
        ".swf"="application/x-shockwave-flash"
        ".sit"="application/x-stuffit"
        ".tcl"="application/x-tcl"
        ".tk"="application/x-tcl"
        ".der"="application/x-x509-ca-cert"
        ".pem"="application/x-x509-ca-cert"
        ".crt"="application/x-x509-ca-cert"
        ".xpi"="application/x-xpinstall"
        ".xhtml"="application/xhtml+xml"
        ".xspf"="application/xspf+xml"
        ".zip"="application/zip"

        ".bin"="application/octet-stream"
        ".exe"="application/octet-stream"
        ".dll"="application/octet-stream"
        ".deb"="application/octet-stream"
        ".dmg"="application/octet-stream"
        ".iso"="application/octet-stream"
        ".img"="application/octet-stream"
        ".msi"="application/octet-stream"
        ".msp"="application/octet-stream"
        ".msm"="application/octet-stream"

        ".docx"="application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        ".xlsx"="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        ".pptx"="application/vnd.openxmlformats-officedocument.presentationml.presentation"

        ".mid"="audio/midi"
        ".midi"="audio/midi"
        ".kar"="audio/midi"
        ".mp3"="audio/mpeg"
        ".ogg"="audio/ogg"
        ".m4a"="audio/x-m4a"
        ".ra"="audio/x-realaudio"

        ".3gpp"="video/3gpp"
        ".3gp"="video/3gpp"
        ".ts"="video/mp2t"
        ".mp4"="video/mp4"
        ".mpeg"="video/mpeg"
        ".mpg"="video/mpeg"
        ".mov"="video/quicktime"
        ".webm"="video/webm"
        ".flv"="video/x-flv"
        ".m4v"="video/x-m4v"
        ".mng"="video/x-mng"
        ".asx"="video/x-ms-asf"
        ".asf"="video/x-ms-asf"
        ".wmv"="video/x-ms-wmv"
        ".avi"="video/x-msvideo"

        # new
        ".wasm"="application/wasm"
    }

    # HTML answer templates for specific calls, placeholders !RESULT, !FORMFIELD, !PROMPT are allowed
    $HTMLRESPONSECONTENTS = @{
        'GET /'  =  @"
<html><body>
    !HEADERLINE
    <pre>!RESULT</pre>
    <form method="POST" action="/download">
    <b>Path to file:</b><input type="text" maxlength=255 size=80 name="filepath" value='!FORMFIELD'>
    <input type="submit" name="button" value="Download">
    </form>
    $(showdir $BASEDIR ".")
</body></html>
"@
        'POST /submit'  =  "!RESULT"
        'POST /query'  =  "!RESULT"
        'GET /query'  =  "!RESULT"
        'POST /fetch'  =  "!RESULT"
        'GET /fetch'  =  "!RESULT"
        'POST /push'  =  "!RESULT"
        'GET /quit' = "<html><body>Stopped powershell webserver</body></html>"
    }

    $HEADERLINE = ""

    # Starting the powershell webserver
    "$(Get-Date -Format s) Starting powershell webserver..."
    $LISTENER = New-Object System.Net.HttpListener
    $LISTENER.Prefixes.Add($BINDING)
    $LISTENER.Start()
    $Error.Clear()

    $EDITCONTENT = ""

    try
    {
        "$(Get-Date -Format s) Powershell webserver started at $BINDING."
        $WEBLOG = "$(Get-Date -Format s) Powershell webserver started at $BINDING.`n"
        while ($LISTENER.IsListening)
        {
            # analyze incoming request
            $CONTEXT = $LISTENER.GetContext()
            $REQUEST = $CONTEXT.Request
            $RESPONSE = $CONTEXT.Response
            $RESPONSEWRITTEN = $FALSE

            # log to console
            "$(Get-Date -Format s) $($REQUEST.RemoteEndPoint.Address.ToString()) $($REQUEST.httpMethod) $($REQUEST.Url.PathAndQuery)"
            # and in log variable
            $WEBLOG += "$(Get-Date -Format s) $($REQUEST.RemoteEndPoint.Address.ToString()) $($REQUEST.httpMethod) $($REQUEST.Url.PathAndQuery)`n"

            # is there a fixed coding for the request?
            $RECEIVED = '{0} {1}' -f $REQUEST.httpMethod, $REQUEST.Url.LocalPath
            $HTMLRESPONSE = $HTMLRESPONSECONTENTS[$RECEIVED]
            $RESULT = ''

            # check for known commands
            switch ($RECEIVED)
            {
                "GET /quit"
                { # stop powershell webserver, nothing to do here
                    break
                }

                "POST /submit" 
                {    
                    if ($REQUEST.HasEntityBody)
                    { # POST request
                        $READER = New-Object System.IO.StreamReader($REQUEST.InputStream, $REQUEST.ContentEncoding)
                        $DATA = $READER.ReadToEnd()
                        $READER.Close()
                        $REQUEST.InputStream.Close()

                        $EDITCONTENT = $DATA

                        # try {
                        #     $EXECUTE = "cmd /c start msedge --app=$BINDING"+"webview.html"
                        #     $RESULT = Invoke-Expression -EA SilentlyContinue $EXECUTE 2> $NULL | Out-String
                        # }
                        # catch
                        # {
                        # }

                        $RESULT = "Succeed"
                    }
                    else
                    { # GET request
                        $RESULT = "No client data received"
                    }
                    break
                }

                { $_ -like "* /query" } 
                {    
                    $RESULT = $EDITCONTENT
                    break
                }

                { $_ -like "* /fetch" } 
                {    
                    $RESULT = $EDITCONTENT
                    break
                }

                "POST /push" 
                {    
                    if ($REQUEST.HasEntityBody)
                    { # POST request
                        $READER = New-Object System.IO.StreamReader($REQUEST.InputStream, $REQUEST.ContentEncoding)
                        $DATA = $READER.ReadToEnd()
                        $READER.Close()
                        $REQUEST.InputStream.Close()

                        $EDITCONTENT = $DATA
                        $RESULT = "Succeed"
                    }
                    else
                    { # GET request
                        $RESULT = "No client data received"
                    }
                    break
                }



                default
                {    # unknown command, check if path to file

                    # create physical path based upon the base dir and url
                    $CHECKDIR = $BASEDIR.TrimEnd("/\") + $REQUEST.Url.LocalPath
                    $CHECKFILE = ""
                    if (Test-Path $CHECKDIR -PathType Container)
                    { # physical path is a directory
                        $IDXLIST = "/index.htm", "/index.html", "/default.htm", "/default.html"
                        foreach ($IDXNAME in $IDXLIST)
                        { # check if an index file is present
                            $CHECKFILE = $CHECKDIR.TrimEnd("/\") + $IDXNAME
                            if (Test-Path $CHECKFILE -PathType Leaf)
                            { # index file found, path now in $CHECKFILE
                                break
                            }
                            $CHECKFILE = ""
                        }
                    }
                    else
                        { # no directory, check for file
                            if (Test-Path $CHECKDIR -PathType Leaf)
                            { # file found, path now in $CHECKFILE
                                $CHECKFILE = $CHECKDIR
                            }
                        }

                    if ($CHECKFILE -ne "")
                    { # static content available
                        try {
                            # ... serve static content
                            $BUFFER = [System.IO.File]::ReadAllBytes($CHECKFILE)
                            $RESPONSE.ContentLength64 = $BUFFER.Length
                            $RESPONSE.SendChunked = $FALSE
                            $EXTENSION = [IO.Path]::GetExtension($CHECKFILE)
                            if ($MIMEHASH.ContainsKey($EXTENSION))
                            { # known mime type for this file's extension available
                                $RESPONSE.ContentType = $MIMEHASH.Item($EXTENSION)
                            }
                            else
                            { # no, serve as binary download
                                $RESPONSE.ContentType = "application/octet-stream"
                                $FILENAME = Split-Path -Leaf $CHECKFILE
                                $RESPONSE.AddHeader("Content-Disposition", "attachment; filename=$FILENAME")
                            }
                            $RESPONSE.AddHeader("Last-Modified", [IO.File]::GetLastWriteTime($CHECKFILE).ToString('r'))
                            $RESPONSE.AddHeader("Server", "Powershell Webserver/1.1 on ")
                            $RESPONSE.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
                            # mark response as already given
                            $RESPONSEWRITTEN = $TRUE
                        }
                        catch
                        {
                            # just ignore. Error handling comes afterwards since not every error throws an exception
                        }
                        if ($Error.Count -gt 0)
                        { # retrieve error message on error
                            $RESULT += "`nError while downloading '$CHECKFILE'`n`n"
                            $RESULT += $Error[0]
                            $Error.Clear()
                        }
                    }
                    else
                    {    
                        $dirstr = (showdir $CHECKDIR $REQUEST.Url.LocalPath)
                        if ($dirstr -ne "not dir"){
                            $HTMLRESPONSE = "<html><body>!HEADERLINE$($dirstr)</body></html>"
                        } else {
                            # no file to serve found, return error
                            $RESPONSE.StatusCode = 404
                            $HTMLRESPONSE = '<html><body>Page not found</body></html>'
                        }
                    }
                }

            }

            # only send response if not already done
            if (!$RESPONSEWRITTEN)
            {
                # insert header line string into HTML template
                $HTMLRESPONSE = $HTMLRESPONSE -replace '!HEADERLINE', $HEADERLINE

                # insert result string into HTML template
                $HTMLRESPONSE = $HTMLRESPONSE -replace '!RESULT', $RESULT

                # return HTML answer to caller
                $BUFFER = [Text.Encoding]::UTF8.GetBytes($HTMLRESPONSE)
                $RESPONSE.ContentLength64 = $BUFFER.Length
                $RESPONSE.AddHeader("Last-Modified", [DATETIME]::Now.ToString('r'))
                $RESPONSE.AddHeader("Server", "Powershell Webserver/1.1 on ")
                $RESPONSE.OutputStream.Write($BUFFER, 0, $BUFFER.Length)
            }

            # and finish answer to client
            $RESPONSE.Close()

            # received command to stop webserver?
            if ($RECEIVED -eq 'GET /quit')
            { # then break out of while loop
                "$(Get-Date -Format s) Stopping powershell webserver..."
                break;
            }
        }
    }
    finally
    {
        # Stop powershell webserver
        $LISTENER.Stop()
        $LISTENER.Close()
        "$(Get-Date -Format s) Powershell webserver stopped."
    }
}

# Start-Webserver "http://+:20202/"
Start-Webserver "http://127.0.0.1:20202/"