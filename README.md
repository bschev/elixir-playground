# Elixir Distributed Key-Value Store

A distributed key-value store created by following the [Elixir Mix and OTP tutorial](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html).

## Requirements

* Elixir - Version 1.4.0 +
* Erlang - Version 18.0 +

## Running The Application (locally)

Deploy the `:kv` application twice with different names in different terminals:

```
apps/kv » elixir --sname foo -S mix run --no-halt
Compiling 6 files (.ex)
Generated kv app

```
```
apps/kv » elixir --sname bar -S mix run --no-halt

```
The `foo` instance will handle all requests for bucket names with first byte in `?a..?m`.
The `bar` instance will handle all requests for bucket names with first byte in `?n..?z`.

Deploy the `:kv_server` application in another terminal:

```
apps/kv_server » elixir --sname server -S mix run --no-halt
Compiling 3 files (.ex)
Generated kv_server app

13:55:03.254 [info]  Accepting connections on port 4040
```

Use a telnet client to access the server:

```
~ » telnet 127.0.0.1 4040
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
CREATE shopping
OK
PUT shopping eggs 6
OK
PUT shopping milk 1
OK
GET shopping eggs
6
OK
DELETE shopping eggs
OK
GET shopping eggs

OK
```

To verify that bucket requests are handled correctly by the `:kv bar` or the `:kv foo` instance, we can stop the `bar` instance. After that a "awesome-list" bucket can be created, a "shopping" bucket not.

```
» telnet 127.0.0.1 4040
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
CREATE awesome-list
OK
CREATE shopping
Connection closed by foreign host.
```

Alternatively the [Observer](http://elixir-lang.org/getting-started/mix-otp/supervisor-and-application.html#observer) can be used to observe the supervision trees of `foo` and `bar`. With each newly created bucket you will see a new process spawned in one of the supervision trees.

## Executing Tests

Start all tests in the umbrella application:

```
» mix test
==> kv
Compiling 6 files (.ex)
Generated kv app
==> kv_server
Compiling 3 files (.ex)
Generated kv_server app
==> kv

15:14:23.278 [info]  Accepting connections on port 4040
Excluding tags: [distributed: true]

.......

Finished in 0.06 seconds
8 tests, 0 failures, 1 skipped

Randomized with seed 293521
==> kv_server
Excluding tags: [distributed: true]

........

Finished in 0.1 seconds
8 tests, 0 failures

Randomized with seed 388141
```

The skipped `KV.RouterTest` test needs two nodes running and the `dev` env configuration:

```
apps/kv » iex --sname bar -S mix
```
```
apps/kv » MIX_ENV=dev elixir --sname foo -S mix test
........

Finished in 0.1 seconds
8 tests, 0 failures

Randomized with seed 117423
```
