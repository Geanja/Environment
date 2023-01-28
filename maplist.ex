defmodule MapList do

  def new() do [] end

  def add(map, value, key) do
    case map do
      [] -> [{key, value}]
      [{keycurrent, _val} | tail] when keycurrent == key -> [{keycurrent, value} | tail]
      [head | tail] -> [head | add(tail, value, key)]
    end
  end

  def lookup(map, key) do
    case map do
      [] -> []
      [{keycurrent, value} | _tail] when keycurrent == key -> {keycurrent, value}
      [_head | tail] -> lookup(tail, key)
    end
  end

  def remove(key, map) do
    case map do
      [] -> []
      [{keycurrent, _value} | tail] when keycurrent == key -> [tail]
      [head | tail] -> [head | remove(key, tail)]
    end
  end

  def bench(i, n) do
    seq = Enum.map(1..i, fn(_) -> :rand.uniform(i) end)
    list = Enum.reduce(seq, new(), fn(e, list) ->
    add(list, e, :foo)
    end)
    seq = Enum.map(1..n, fn(_) -> :rand.uniform(i) end)
    start_time = :erlang.monotonic_time()
    Enum.each(seq, fn(e) ->
    add(list, e, :foo)
    end)
    add_time = :erlang.monotonic_time() - start_time

    start_time = :erlang.monotonic_time()
    Enum.each(seq, fn(e) ->
    lookup(list, e)
    end)
    lookup_time = :erlang.monotonic_time() - start_time

    start_time = :erlang.monotonic_time()
    Enum.each(seq, fn(e) ->
    remove(e, list)
    end)
    remove_time = :erlang.monotonic_time() - start_time

    {i, add_time, lookup_time, remove_time}
  end

  def bench(n) do
    ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024]
    :io.format("# benchmark with ~w operations, time per operation in ns\n", [n])
    :io.format("~6.s~13.s~17.s~16.s\n", ["n", "add", "lookup", "remove"])
    Enum.each(ls, fn (i) ->
    {i, tla, tll, tlr} = bench(i, n)
    #Format to put in a tex table
    :io.format("~6.w &~12.2f & ~12.2f & ~12.2f \\\\ \n", [i, tla/n, tll/n, tlr/n])
            end)
  end
end
