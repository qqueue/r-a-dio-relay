#!/usr/bin/env liquidsoap
# Liquidsoap script for opus stream relay

%include "config.liq"
# Relay original stream
radio = input.http(
	timeout=30.,
	poll_delay=.5,
	new_track_on_metadata=true,
	buffer=.5,
	id="original-r-a-dio",
	STREAM_URL
)

# Fallback if stream goes offline
#fb = single(FALLBACK_PATH)
fb = amplify(.1, noise())
fb = rewrite_metadata([
	("title", "r/a/dio Stream down at the moment, stay tuned on r-a-d.io!"),
	("artist", "r/a/dio")
], fb)

# Fallback to offline audio file
radio = fallback(id="fb_fallback2", track_sensitive=false, [radio, fb])

# Make stream safe for shout
radio = mksafe(radio)

# Relay original stream
eden = input.http(
	timeout=30.,
	poll_delay=.5,
	new_track_on_metadata=true,
	buffer=.5,
	id="original-eden",
  "http://edenofthewest.com:8080/eden.mp3"
)

# Fallback if stream goes offline
#fb = single(FALLBACK_PATH)
fbe = amplify(.1, noise())
fbe = rewrite_metadata([
	("title", "eden Stream down at the moment, stay tuned on edenofthewest.com!"),
	("artist", "edenofthewest")
], fbe)

# Fallback to offline audio file
eden = fallback(id="fb_fallback3", track_sensitive=false, [eden, fbe])

# Make stream safe for shout
eden = mksafe(eden)

shout = output.icecast(
	password=ICECAST_PASSWORD,
	description=ICECAST_DESCRIPTION,
	name=ICECAST_NAME,
	genre=ICECAST_GENRE,
	public=ICECAST_PUBLIC,
	user=ICECAST_USERNAME,
	port=ICECAST_PORT,
	host=ICECAST_HOST
)

edenshout = output.icecast(
	password=ICECAST_PASSWORD,
	description="edenofthewest opus relay",
	name= "edenofthewest",
	genre="Various",
	public=ICECAST_PUBLIC,
	user=ICECAST_USERNAME,
	port=ICECAST_PORT,
	host=ICECAST_HOST
)

shout(
	mount="/r-a-dio",
	%opus(bitrate=64,vbr="unconstrained"), radio
)

edenshout(
	mount="/edenofthewest",
	%opus(bitrate=64,vbr="unconstrained"), eden
)
