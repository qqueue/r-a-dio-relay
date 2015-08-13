// Generated by LiveScript 1.2.0
var icy, cp, http, https, METAINT;
icy = require('icy');
cp = require('child_process');
http = require('http');
https = require('https');
METAINT = 16000;
http.createServer(function(req, res){
  var get;
  if (req.method !== 'GET') {
    res.statusCode = 405;
    res.end();
    return;
  }
  if (req.url !== '/stream.ogg') {
    res.statusCode = 404;
    res.end();
    return;
  }
  get = https.get({
    host: 'stream.r-a-d.io',
    path: '/main.mp3',
    headers: {
      'Icy-MetaData': 1
    }
  }, function(hres){
    var i, w, mpg321, oggenc;
    i = new icy.Reader(hres.headers['icy-metaint']);
    hres.pipe(i);
    w = new icy.Writer(METAINT);
    i.on('metadata', function(m){
      console.error(icy.parse(m));
      w.queue(icy.parse(m));
    });
    mpg321 = cp.spawn('mpg321', ['-q', '-s', '-']);
    mpg321.stderr.pipe(process.stderr);
    i.pipe(mpg321.stdin);
    oggenc = cp.spawn('oggenc', ['-Q', '-r', '-b', '48', '-']);
    oggenc.stderr.pipe(process.stderr);
    mpg321.stdout.pipe(oggenc.stdin);
    res.writeHead(200, {
      'Content-Type': 'audio/ogg',
      'icy-name': 'r/a/dio.opus',
      'icy-metaint': METAINT
    });
    oggenc.stdout.pipe(w);
    w.pipe(res);
    res.on('close', function(){
      oggenc.kill();
      mpg321.kill();
      get.abort();
      console.error('closed!');
    });
  });
  return get.on('error', function(e){
    console.error(e);
    res.end(500);
  });
}).listen(process.argv[2], function(){
  console.error("listening on " + process.argv[2]);
});