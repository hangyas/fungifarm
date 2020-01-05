# Fungifarm

## Run

```
iex --name fungifarm@192.168.1.11 --cookie (cat cookie) -S mix phx.server
```

## Apps

**farmunit:** application running on the raspberry, sensors and basic automation control

**fungifarm:** main application running on the server, db connection, etc.

**fungifarm_web:** web interface

**fungifarm_shared:** code shared between the farmunit and the fungifarm

## Connection

`farmunit`s connect to the `fungifarm` server (`FarmUnit.ServerConnector`) (address is in the configuration), send their metadata (`FarmunitRegistry.register`), monitor the connection and reconnect if need be

`fungifarm` and `fungifarm_web` subscribe to the messages emitted by the `farmunit`s, might send control messages (`Uplink`, `FarmunitRegistry`)

## TODO

 - [ ] log `farmunit` failures on `fungifarm`
