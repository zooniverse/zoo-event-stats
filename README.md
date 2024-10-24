[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)

# zoo-event-stats (DEPRECATED STATS SERVICE. ONLY USED TO PUSH DATA TO PUSHER PUBLIC DATA STREAM)

DEPRECATED STATS SERVICE. Replaced with ERAS: https://github.com/zooniverse/eras. This service is only used to push data to Pusher public data stream. 

#### Stream Reader

This service contains a Kinesis stream reader for the internal Zooniverse data stream.
Each record on the input stream is processed if it's a talk comment or classification event.
Processing involves tranforming the incoming data and
pushing data into the Pusher public data stream (public data only).

See [KCLReader](./lib/input/kcl_reader.rb) and [start_stream](./bin/start_stream) for more details.


#### Getting Started

1. Run the app with `docker-compose up`

0. Open up the application in your browser at http://localhost:3000

Once all the above steps complete you will have a working copy of the checked out code base. Keep your code up to date and rebuild the image on any code or configuration changes.

## Development

1. Build the local image for development
    * Run: `docker-compose build`

0. Run the tests
    * Run: `docker-compose run -T --rm api bundle exec rake test`

0. Get a console to interactively run / debug tests
    * Run: `docker-compose run --rm --service-ports api /bin/bash`
    * Then in the container run: `bundle exec rake test`


Note: To update Gems from the api container you'll need to run `bundle install --with stream`. This is due to the way the stream & api docker images differ with how their gems are installed via groups. See `bundle config` in the container for details of what groups are installed.

### Setup Docker and Docker Compose

* Docker
  * [OS X](https://docs.docker.com/installation/mac/) - Docker Machine
  * [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) - Docker
  * [Windows](http://docs.docker.com/installation/windows/) - Boot2Docker

* [Docker Compose](https://docs.docker.com/compose/)

This product includes GeoLite2 data created by MaxMind, available from
<a href="http://www.maxmind.com">http://www.maxmind.com</a>.
