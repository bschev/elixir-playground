# Check if the node is alive on the network, if not, exclude all distributed tests.
exclude =
  if Node.alive?, do: [], else: [distributed: true]

ExUnit.start(exclude: exclude)
