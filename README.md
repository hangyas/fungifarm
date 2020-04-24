# Fungifarm

## Build

```
env MIX_ENV=prod mix release farmunit
scp -r _build/prod/rel/farmunit/ pi@192.168.1.10:/home/pi
```

## Run

```
iex --name fungifarm@192.168.1.11 --cookie (cat cookie) -S mix phx.server
```

## Test

```
mix test
# or
mix test --exclude slow:true
# or
mix test --exclude database:Fungifarm.Database.MongoImpl
```

## Attach

observer

```
iex --name "laptop" --cookie (cat cookie)
Node.connect :"fat_farmunit@192.168.1.10"
:observer.start
```

remote

```
_build/prod/rel/fat_farmunit/bin/fat_farmunit remote
````

## Apps

**farmunit:** application running on the raspberry, sensors and basic automation control
 - connects to the `fungifarm` node - but keeps running without it
 - emits measurement data into the `"sensor_subscribers:<unit-name>"` group and store the into a `PulletMQ`

**fungifarm:** main application running on the server, db connection, etc.
 - read data from the connected units' `"measurement:<unit-name>"`
 - saves/loads data from db

**fungifarm_web:** web interface
 - can connect to `fungifarm` and `farmunit` to monitor them in real time

**fungifarm_shared:** code shared between the farmunit and the fungifarm

## Connection

`farmunit`s connect to the `fungifarm` server (`Uplink`) (address is in the configuration). Announces themselves with an rpc call to `Fungifarm.SinkManager`. `Fungifarm.SinkManager` creates a `DataSink` for the measurement queue defined in the unit's metadata. `SinkManager` also gets all the units at startup from the `:uplinks` group.

`fungifarm_web` or any other process can later find all units and their processes via `:syn`

## important syn names

 - `"measurement:<unit-name>"`: PulletMQ on every unit
 - `Fungifarm.SinkManager`: Starts a `DataSink` for every measurement queue - actually only used by locally, through `SinkManager`'s frontend

groups

 - `:uplinks`
 - `"sensor_subscribers:<unit-name>"`: subscribers for immediate sensor updates (`FarmUnit.MeasurementsLoader`) joins this too

Unit specific names are in `FarmUnit.Procnames`

## TODO

 - [x] use syn groups for PubSub?
 - [x] exclude mongo tests + clean the db before they run
 - [ ] clean up sensor code
 - [ ] change mongodb driver
 - [ ] test on raspberry
 - [ ] option to share db between PulletMQ instances
 - [x] maybe pipe messages from PubSub right into PulletMQ
 - [x] https://github.com/ostinelli/syn
 - [ ] https://github.com/keathley/vapor/
 - [ ] [add web based observer](https://github.com/zorbash/observer_live)
 - [ ] log `farmunit` failures on `fungifarm`
 - [ ] update phoenix to 1.5 and use liveview generators
 - [ ] update `fungifarm_web` to the recent changes
