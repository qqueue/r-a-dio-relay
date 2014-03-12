######################################################
# Liquidsoap configuration file for the restreamer
######################################################

####################
# LIQUIDSOAP SETUP
####################

# Some liquidsoap logging configuration
# Refer to the documentation for more info about these
# settings.
set("log.stdout", true)
set("log.file", true)
set("log.file.path", "./<script>.log")

# Original stream URL
STREAM_URL = "http://r-a-d.io/main.mp3"

# Icecast mountpoint/stream settings
ICECAST_HOST = "127.0.0.1"
ICECAST_PORT = 8000
ICECAST_PASSWORD = "hackme"
ICECAST_USERNAME = "source" #default is "source"
ICECAST_PUBLIC = false
ICECAST_DESCRIPTION = "r/a/dio opus relay"
ICECAST_NAME = "r/a/dio opus"
ICECAST_GENRE = "Various"

# Stream fallback (yet to be solved properly)
#FALLBACK_PATH = "offline.wav"
