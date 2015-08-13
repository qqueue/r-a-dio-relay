require! {
  icy
  #lame
  #ogg
  #opus: \node-opus
  #vorbis
  cp: child_process
  http
  https
}

METAINT = 16_000

http.create-server (req, res) ->
  if req.method is not \GET
    res.status-code = 405
    res.end!
    return
  if req.url is not \/stream.ogg
    res.status-code = 404
    res.end!
    return
  get = https.get do
    host: \stream.r-a-d.io
    path: \/main.mp3
    headers: 'Icy-MetaData' : 1
    (hres) !->
      i = new icy.Reader hres.headers[\icy-metaint]
      hres.pipe i
      w = new icy.Writer METAINT
      i.on \metadata (m) !->
        console.error icy.parse m
        w.queue icy.parse m
      #raw = rres.pipe new lame.Decoder
      #ve = new opus.Encoder
      #raw.pipe ve
      #oe = new ogg.Encoder
      #ve.pipe oe.stream!
      #oe.pipe w

      # XXX ^ native node code breaks somewhere,
      # so just pipe through the usual external processes,
      # leaving just icy metadata (and http) to node

      mpg321 = cp.spawn \mpg321 [\-q \-s \-]
      mpg321.stderr.pipe process.stderr
      i.pipe mpg321.stdin

      oggenc = cp.spawn \oggenc [\-Q \-r \-b \48 \-]
      oggenc.stderr.pipe process.stderr
      mpg321.stdout.pipe oggenc.stdin

      res.write-head 200,
        \Content-Type : \audio/ogg
        \icy-name : \r/a/dio.opus
        \icy-metaint : METAINT

      oggenc.stdout.pipe w
      #oggenc.stdout.pipe res
      w.pipe res

      res.on \close !->
        oggenc.kill!
        mpg321.kill!
        get.abort!
        console.error \closed!

  get.on \error (e) !->
    console.error e
    res.end 500
.listen process.argv[2], !->
  console.error "listening on #{process.argv[2]}"

