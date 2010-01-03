#
#
#            Nimrod's Runtime Library
#        (c) Copyright 2010 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements a simple HTTP-Server. 

import strutils, os, osproc, strtabs, streams, sockets

const
  wwwNL = "\r\L"
  ServerSig = "Server: httpserver.nim/1.0.0" & wwwNL

# --------------- output messages --------------------------------------------

proc sendTextContentType(client: TSocket) =
  send(client, "Content-type: text/html" & wwwNL)
  send(client, wwwNL)

proc badRequest(client: TSocket) =
  # Inform the client that a request it has made has a problem.
  send(client, "HTTP/1.0 400 BAD REQUEST" & wwwNL)
  sendTextContentType(client)
  send(client, "<p>Your browser sent a bad request, " &
               "such as a POST without a Content-Length." & wwwNL)

proc cannotExec(client: TSocket) =
  send(client, "HTTP/1.0 500 Internal Server Error" & wwwNL)
  sendTextContentType(client)
  send(client, "<P>Error prohibited CGI execution." & wwwNL)

proc headers(client: TSocket, filename: string) = 
  # XXX could use filename to determine file type
  send(client, "HTTP/1.0 200 OK" & wwwNL)
  send(client, ServerSig)
  sendTextContentType(client)

proc notFound(client: TSocket) =
  send(client, "HTTP/1.0 404 NOT FOUND" & wwwNL)
  send(client, ServerSig)
  sendTextContentType(client)
  send(client, "<html><title>Not Found</title>" & wwwNL)
  send(client, "<body><p>The server could not fulfill" & wwwNL)
  send(client, "your request because the resource specified" & wwwNL)
  send(client, "is unavailable or nonexistent." & wwwNL)
  send(client, "</body></html>" & wwwNL)

proc unimplemented(client: TSocket) =
  send(client, "HTTP/1.0 501 Method Not Implemented" & wwwNL)
  send(client, ServerSig)
  sendTextContentType(client)
  send(client, "<html><head><title>Method Not Implemented" & 
               "</title></head>" &
               "<body><p>HTTP request method not supported." &
               "</body></HTML>" & wwwNL)

# ----------------- file serving ---------------------------------------------

proc discardHeaders(client: TSocket) = skip(client)

proc serveFile(client: TSocket, filename: string) =
  discardHeaders(client)
  
  var f: TFile
  if open(f, filename):
    headers(client, filename)
    const bufSize = 8000 # != 8K might be good for memory manager
    var buf = alloc(bufsize)
    while True:
      var bytesread = readBuffer(f, buf, bufsize)
      if bytesread > 0:
        var byteswritten = send(client, buf, bytesread)
        if bytesread != bytesWritten:
          dealloc(buf)
          close(f)
          OSError()
      if bytesread != bufSize: break
    dealloc(buf)
    close(f)
  else:
    notFound(client)

# ------------------ CGI execution -------------------------------------------

type
  TRequestMethod = enum reqGet, reqPost

proc executeCgi(client: TSocket, path, query: string, meth: TRequestMethod) =
  var env = newStringTable(modeCaseInsensitive)
  var contentLength = -1
  case meth
  of reqGet:
    discardHeaders(client)
    
    env["REQUEST_METHOD"] = "GET"
    env["QUERY_STRING"] = query
  of reqPost:
    var buf = ""
    var dataAvail = false
    while dataAvail:
      dataAvail = recvLine(client, buf)
      var L = toLower(buf)
      if L.startsWith("content-length:"):
        var i = len("content-length:")
        while L[i] in Whitespace: inc(i)
        contentLength = parseInt(copy(L, i))
    
    if contentLength < 0:
      badRequest(client)
      return

    env["REQUEST_METHOD"] = "POST"
    env["CONTENT_LENGTH"] = $contentLength
  
  send(client, "HTTP/1.0 200 OK" & wwwNL)
  
  var process = startProcess(command=path, env=env)
  if meth == reqPost:
    # get from client and post to CGI program:
    var buf = alloc(contentLength)
    if recv(client, buf, contentLength) != contentLength: OSError()
    var inp = process.inputStream
    inp.writeData(inp, buf, contentLength)
  
  var outp = process.outputStream
  while running(process) or not outp.atEnd(outp):
    var line = outp.readLine()
    send(client, line)
    send(client, wwwNL)

# --------------- Server Setup -----------------------------------------------

proc startup(): tuple[socket: TSocket, port: TPort] =
  var s = socket(AF_INET)
  if s == InvalidSocket: OSError()
  bindAddr(s)
  listen(s)
  result.socket = s
  result.port = getSockName(s)

proc acceptRequest(client: TSocket) =
  var cgi = false
  var query = ""
  var buf = ""
  discard recvLine(client, buf)
  var data = buf.split()
  var meth = reqGet
  if cmpIgnoreCase(data[0], "GET") == 0:
    var q = find(data[1], '?')
    if q >= 0:
      cgi = true
      query = data[1].copy(q+1)
  elif cmpIgnoreCase(data[0], "POST") == 0:
    cgi = true
    meth = reqPost
  else:
    unimplemented(client)
    
  var path = data[1]
  if path[path.len-1] == '/' or existsDir(path):
    path = path / "index.html"
  
  if not ExistsFile(path):
    discardHeaders(client)
    notFound(client)
  else:
    when defined(Windows):
      var ext = splitFile(path).ext.toLower
      if ext == ".exe" or ext == ".cgi":
        # XXX: extract interpreter information here?
        cgi = true
    else:
      if {fpUserExec, fpGroupExec, fpOthersExec} * path.getFilePermissions != {}:
        cgi = true
    if not cgi:
      serveFile(client, path)
    else:
      executeCgi(client, path, query, meth)

proc main =  
  var (server, port) = startup()
  echo("httpserver running on port ", int16(port))
  
  while true:
    var client = accept(server)
    if client == InvalidSocket: OSError()
    acceptRequest(client)
    close(client)
  close(server)

when isMainModule:
  main()
