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
 - send measurement data for processing to `que` (processed and saved by `fungifarm`)
 - measurement data is first emited with `PubSub` - subscribed by `fungifarm_web`, and by itself

**fungifarm:** main application running on the server, db connection, etc.
 - keeps track of running farmunits
 - processes `que` jobs
 - saves/loads data from db

**fungifarm_web:** web interface
 - can connect to `fungifarm` and `farmunit` to monitor them in real time

**fungifarm_shared:** code shared between the farmunit and the fungifarm

## Connection

`farmunit`s connect to the `fungifarm` server (`FarmUnit.ServerConnector`) (address is in the configuration), send their metadata (`FarmunitRegistry.register`), monitor the connection and reconnect if need be

`fungifarm` and `fungifarm_web` subscribe to the messages emitted by the `farmunit`s, might send control messages (`Uplink`, `FarmunitRegistry`)

## TODO

 - [ ] log `farmunit` failures on `fungifarm`
 - [x] https://github.com/ostinelli/syn
 - [ ] https://github.com/keathley/vapor/
 - [ ] option to share db between PulletMQ instances
 - [ ] [add web base observer](https://github.com/zorbash/observer_live)
 - [ ] maybe pipe messages from PubSub right into PulletMQ
