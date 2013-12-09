clipGif
=======

Just a simple wrapper to automate the creation of animated gifs from video clips.  It uses/requires ffmpeg to pull the frames out of the video file and gifsicle to assemble the frames into an animated gif.

Features
========

* specify delay between frames
* rewind (to create seemless loops
* all work is done in a temp directory
* the temporary directory and the finished GIF are opened (this is the OSX specific pieces)
* creates a bash script named "reGif.command" to enable recreation of the GIF after manual removal (or editing of frames)

Planned Features
================

* Handle other POSIX OS's better
* calculate/translate seconds into the duration string
* non-looping gifs

Usage
=====

clipGif InputFile StartTime Length [FrameDelay] [Rewind]
* InputFile: the video file to use as input
* StartTime: where to begin extracting frames, in the form of HH:MM:SS
* Length: how long of a clip to extract, in the form of HH:MM:SS
* FrameDeloy (optional): the delay between frames
* Rewind (optional): Whether or not to add reverse playback. This creates seemless loops.
