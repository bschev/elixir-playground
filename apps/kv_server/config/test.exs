use Mix.Config

config :kv, :routing_table,
       [{?a..?z, node()}]
