use Mix.Config

# Overwrite the :routing_table configuration.
config :kv, :routing_table,
       [{?a..?z, node()}]
