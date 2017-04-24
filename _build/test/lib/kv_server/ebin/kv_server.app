{application,kv_server,
             [{applications,[kernel,stdlib,elixir,logger,kv]},
              {description,"kv_server"},
              {modules,['Elixir.KVServer','Elixir.KVServer.Application']},
              {registered,[]},
              {vsn,"0.1.0"},
              {extra_applications,[logger]},
              {mod,{'Elixir.KVServer.Application',[]}}]}.
