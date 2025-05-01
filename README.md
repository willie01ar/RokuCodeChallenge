# Paramount+ Code Challenge

This is the code base for the Paramount+ Code Challenge

# Notes

* The UI is does not support low res devices, running on 720p will break the keyboard overlay UI
* Video playback is done in a separate screen, no overlay, to simplify focus management
* User exit the video playback by pressing OK
* The OMDbAPI response contains some missing or broken images, the tile widget attempt to provide a place holder for those


# Configure Deploy scrips

Run `npm install` to gather all the dependencies you need.
Make sure you have gulp-cli installed `npm install -g gulp-cli` 
Make sure you update the right credentials in `./gulpfile.js/deploy.js` 

* `gulp configure`: Configures your build interactively
* `gulp logs`: Connects to the configured IP address via `telnet` to view logs. All key strokes are passed through
* `gulp deploy`: Builds and deploys this channel to the Roku device at the configured IP address
* `gulp clean`: Removes build artifacts.  Happens automatically so you likely won't need to do this often.
* `gulp build`: Builds this channel without deploying it.  See the `bin/` directory for results.
