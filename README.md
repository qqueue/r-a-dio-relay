# r/a/dio opus restreamer

A little glue script to transcode [r/a/dio](https://r-a-d.io) into
glorious low-bitrate opus for more efficient streaming over cell networks.

The actual code is about as complex as this CGI script:

    echo 200 OK HTTP/1.0
    curl https://stream.r-a-d.io/main.mp3 |\
    mpg321 -q -s - |\
    oggenc -Q -r -b 48 -

But I wanted to preserve the shoutcast metadata present in the original
stream. The only standalone parser I found was [node-icy][0], thus
the relay script is in (glorious) node, with thin wrappers
around mpg321 and oggenc (the node library equivalents didn't work for me).

[0]: https://github.com/TooTallNate/node-icy

## Usage

    node relay.sh 8856 # or some other port

then open http://localhost:8556/stream.ogg in your favorite player. On android,
the only game in town with opus support appears to be the Very Large Cone.

Right now the script assumes your client can decode 
(shoutcast/icecast in-band metadata)[1]. If you can't handle it, you could edit
the script or something.

[1]: http://www.smackfu.com/stuff/programming/shoutcast.html
