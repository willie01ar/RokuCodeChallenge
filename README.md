# Paramount+ Code Challenge

This is the code base for the Paramount+ Code Challenge

# Notes

* The UI is does not support low res devices, running on 720p will break the keyboard overlay UI
* Video playback is done in a separate screen, no overlay, to simplify focus management
* User exit the video playback by pressing OK
* The OMDbAPI response contains some missing or broken images, the tile widget attempt to provide a place holder for those


# To Deploy

There is no build process implemented.  Just zip up the entire project (excluding the rather large .git directory).  Make sure the zip process leaves the *manifest* file in the root path.  

There's a convenience tool for doing this from the command line, which we recommend (see [github page](https://github.com/hulu/roku-dev-cli) for usage).    

```shell
pip3 install roku-dev-cli
```
