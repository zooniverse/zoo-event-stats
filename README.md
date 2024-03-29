[![pullreminders](https://pullreminders.com/badge.svg)](https://pullreminders.com?ref=badge)

# zoo-event-stats
Event stream reader and JSON stats API for Zooniverse wide and project classification and comment counts.

#### Stream Reader

This service contains a Kinesis stream reader for the internal Zooniverse data stream.
Each record on the input stream is processed if it's a talk comment or classification event.
Processing invovles tranforming the incoming data and
pushing data into both the Elastic Search data store and to the Pusher public data stream (public data only).

See [KCLReader](./lib/input/kcl_reader.rb) and [start_stream](./bin/start_stream) for more details.

#### API
The stats service has a json API to query the event counts for projects

##### `GET /counts/$event_type/$period?user_id=1&project_id=1`
Get the counts of events that match the event type over the period.

Valid `$event_type` values are `classification` and `comment`.

Valid `$period` values are `minute`, `hour`, `day`, `week`, `month`, `quarter`, `year`.
More details at [Value ES period values](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-datehistogram-aggregation.html#_calendar_intervals)

Valid `?user_id` values are integers, e.g. `1`

Valid `?project_id` values are integers or a comma seperated list, e.g. `1` or `1,2,3`

This end points returns json data in the format below where the each period will return an object in the buckets list.
```
{
    "events_over_time": {
        "buckets": [
            {
                "key_as_string": "2016-06-13T00:00:00.000Z",
                "key":1465776000000,
                "doc_count":25
            }
        ]
    }
}
```

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

0. Seed some data into elastic search
    * Then in the container run: `bundle exec rake seed_es_dev_data`

Note: To update Gems from the api container you'll need to run `bundle install --with stream`. This is due to the way the stream & api docker images differ with how their gems are installed via groups. See `bundle config` in the container for details of what groups are installed.

### Setup Docker and Docker Compose

* Docker
  * [OS X](https://docs.docker.com/installation/mac/) - Docker Machine
  * [Ubuntu](https://docs.docker.com/installation/ubuntulinux/) - Docker
  * [Windows](http://docs.docker.com/installation/windows/) - Boot2Docker

* [Docker Compose](https://docs.docker.com/compose/)

This product includes GeoLite2 data created by MaxMind, available from
<a href="http://www.maxmind.com">http://www.maxmind.com</a>.
