require! {
  icy
  #lame
  #ogg
  #opus: \node-opus
  #vorbis
  child_process: cp
  http
  request
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
  err = (e) !->
    console.error e
    try
      res.end 500
    catch
      console.error e
  # XXX no obvious way to pipe the streaming response body
  # into icy.Reader while still having access to the headers.
  # I'm imagining something like
  # request(...).pipe((res) -> new icy.Reader res.headers[\icy-metaint]))
  # where it'll initialize the pipe once we get the res with headers.
  # there's probably a way to twist the stream module to Do What We Want™
  # but my patience for nodejs apis has faded.
  # thus, just assume the Icy-Metaint is always 16000.
  # we could (and used to) just use the vanilla https core module
  # which supports streaming + headers, but it doesn't do redirects.

  get = request do
    uri: \https://stream.r-a-d.io/main.mp3
    headers: 'Icy-MetaData' : 1

  get.on \error err
  i = new icy.Reader METAINT # XXX res.headers[\icy-metaint]
  i.on \error err

  get.pipe i

  w = new icy.Writer METAINT
  w.on \error err
  i.on \metadata (m) !->
    console.error icy.parse m
    w.queue icy.parse m

  # XXX native node code breaks somewhere,
  # so just pipe through the usual external processes,
  # leaving just icy metadata (and http) to node
  #raw = rres.pipe new lame.Decoder
  #ve = new opus.Encoder
  #raw.pipe ve
  #oe = new ogg.Encoder
  #ve.pipe oe.stream!
  #oe.pipe w

  mpg321 = cp.spawn \mpg321 [\-q \-s \-]
  mpg321.stderr.pipe process.stderr
  mpg321.on \error err
  i.pipe mpg321.stdin

  oggenc = cp.spawn \oggenc [\-Q \-r \-b \64 \-]
  oggenc.stderr.pipe process.stderr
  oggenc.on \error err
  mpg321.stdout.pipe oggenc.stdin

  res.write-head 200,
    \Content-Type : \audio/ogg
    \icy-name : \r/a/dio.opus
    \icy-metaint : METAINT

  oggenc.stdout.pipe w
  w.pipe res

  res.on \close !->
    oggenc?kill!
    mpg321?kill!
    get?abort!
    console.error \closed!

.listen process.argv[2], !->
  console.error "listening on #{process.argv[2]}"

