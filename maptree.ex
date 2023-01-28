defmodule EnvTree do

  def add(nil, value, key) do
    {:node, key, value, nil, nil}
  end

  def add({:node, k, _, left, right}, value, key) when k == key do
      {:node, k, value, left, right}
  end

  def add({:node, k, v, left, right}, value, key) when key < k do
      {:node, k, v, add(left, value, key), right}
  end

  def add({:node, k, v, left, right}, value, key) do
      {:node, k, v, left, add(right, value, key)}
  end

  def lookup(nil, _) do nil end

  def lookup({:node, k, v, _left, _right}, key) when k == key do
    {k, v}
  end

  def lookup({:node, k, _v, left, _right}, key) when key < k do
    lookup(left, key)
  end

  def lookup({:node, _k, _v, _left, right}, key) do
    lookup(right, key)
  end

  def remove(nil, _) do nil end

  def remove({:node, k, _, nil, right}, key) when k == key do
    right
  end

  def remove({:node, k, _, left, nil}, key)  when k == key do
    left
  end

  def remove({:node, k, _, left, right}, key) when k == key do
  leftNodeInRight = leftmost(right)
  {:node, elem(leftNodeInRight, 0), elem(leftNodeInRight, 1), left, remove(right, elem(leftNodeInRight, 0))}
  end

  def remove({:node, k, v, left, right}, key) when key < k do
  {:node, k, v, remove(left, key), right}
  end

  def remove({:node, k, v, left, right}, key) do
  {:node, k, v, left, remove(right, key)}
  end

  def leftmost({:node, key, value, nil, _rest}) do
    {key, value}
  end

  def leftmost({:node, _k, _v, left, _right}) do
  leftNode = leftmost(left)
  leftNode
  end

  def bench(i, n) do
    seq = Enum.map(1..i, fn(_) -> :rand.uniform(i) end)
    list = Enum.reduce(seq, add(:nil, :rand.uniform(i), :value), fn(e, list) -> add(list, e, :foo)end)
    seq = Enum.map(1..n, fn(_) -> :rand.uniform(i) end)
    start_time = :erlang.monotonic_time()
    Enum.each(seq, fn(e) ->
    add(list, e, :foo)
              end)
    end_time = :erlang.monotonic_time()
    add_time = end_time - start_time

    start_time = :erlang.monotonic_time()
    Enum.each(seq, fn(e) ->
    lookup(list, e)
            end)
    end_time = :erlang.monotonic_time()
    lookup_time = end_time - start_time

    start_time = :erlang.monotonic_time()
    Enum.each(seq, fn(e) ->
    remove(list, e)
            end)
    end_time = :erlang.monotonic_time()
    remove_time = end_time - start_time

    {i, add_time, lookup_time, remove_time}
  end

  def bench(n) do
    ls = [16,32,64,128,256,512,1024,2*1024,4*1024,8*1024]
    :io.format("# benchmark with ~w operations, time per operation in ns\n", [n])
    :io.format("~6.s~13.s~17.s~16.s\n", ["n", "add", "lookup", "remove"])
    Enum.each(ls, fn (i) ->
    {i, tla, tll, tlr} = bench(i, n)
    :io.format("~6.w &~12.2f & ~12.2f & ~12.2f \\\\ \n", [i, tla/n, tll/n, tlr/n])
            end)
  end
end
