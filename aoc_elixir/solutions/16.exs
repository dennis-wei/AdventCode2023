defmodule Day16 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/16.txt"
      true -> "test_input/16.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  @transitions %{
    {:right, "|"} => [:up, :down],
    {:right, "\\"} => [:down],
    {:right, "/"} => [:up],
    {:right, "-"} => [:right],
    {:right, "."} => [:right],

    {:left, "|"} => [:up, :down],
    {:left, "\\"} => [:up],
    {:left, "/"} => [:down],
    {:left, "-"} => [:left],
    {:left, "."} => [:left],

    {:up, "|"} => [:up],
    {:up, "\\"} => [:left],
    {:up, "/"} => [:right],
    {:up, "-"} => [:left, :right],
    {:up, "."} => [:up],

    {:down, "|"} => [:down],
    {:down, "\\"} => [:right],
    {:down, "/"} => [:left],
    {:down, "-"} => [:left, :right],
    {:down, "."} => [:down]
  }

  @dirm %{
    :left => {-1, 0},
    :right => {1, 0},
    :up => {0, -1},
    :down => {0, 1}
  }


  def step(grid, {lasers, energized}) do
    ulasers = Enum.flat_map(lasers, fn {{x, y}, dir} ->
      Process.put({{x, y}, dir}, true)
      {dx, dy} = Map.get(@dirm, dir)
      {ux, uy} = {x + dx, y + dy}
      val = Map.get(grid, {ux, uy}, nil)
      case val do
        nil -> []
        v ->
          next = Map.get(@transitions, {dir, v}, nil)
          case next do
            nil -> raise "Invalid transition: #{dir} #{v}"
            nlasers ->
              Enum.map(nlasers, fn udir -> {{ux, uy}, udir} end)
          end
      end
    end)
      |> Enum.filter(fn l -> l != nil end)
      |> Enum.filter(fn l -> !MapSet.member?(energized, l) end)
    uenergized = Enum.reduce(lasers, energized, fn l, acc ->
      MapSet.put(acc, l)
    end)
    {ulasers, uenergized}
  end

  def run(grid, initial_lasers) do
    initial = {initial_lasers, MapSet.new}
    res = Enum.reduce_while(0..100000, initial, fn _i, acc ->
      {_plasers, penergized} = acc
      {lasers, energized} = step(grid, acc)
      cond do
        lasers == [] ->
          {:halt, energized}
        energized == penergized ->
          {:halt, energized}
        true -> {:cont, {lasers, energized}}
      end
    end)
    case res do
      {_lasers, _energized} -> raise "Unfinished"
      n -> n
    end
  end

  def solve(test \\ true, part2 \\ false) do
    {grid, {mx, my}} = get_input(test)
      |> Enum.map(&String.graphemes/1)
      |> Grid.make_grid_with_size(true)
    energized = run(grid, [{{0, 0}, :right}])
    part1 = energized
      |> Enum.map(fn {{x, y}, _} -> {x, y} end)
      |> MapSet.new
      |> MapSet.delete({-1, 0})
      |> MapSet.size

    half_size = ceil(mx / 2)
    [t1, t2] = Enum.reduce(0..mx-1, [], fn x, acc ->
      [[{{x, 0}, :down}] | acc]
    end)
      |> Enum.chunk_every(half_size)
    [b1, b2] = Enum.reduce(0..mx-1, [], fn x, acc ->
      [[{{x, my-1}, :up}] | acc]
    end)
      |> Enum.chunk_every(half_size)
    [l1, l2] = Enum.reduce(0..my-1, [], fn y, acc ->
      [[{{0, y}, :right}] | acc]
    end)
      |> Enum.chunk_every(half_size)
    [r1, r2] = Enum.reduce(0..my-1, [], fn y, acc ->
      [[{{mx-1, y}, :left}] | acc]
    end)
      |> Enum.chunk_every(half_size)

    case part2 do
      true ->
        tasks = Enum.map([t1, t2, r1, r2, b1, b2, l1, l2], fn to_test ->
          Task.async(fn ->
            Enum.map(to_test, fn starting ->
              res = run(grid, starting)
                |> Enum.map(fn {{x, y}, _} -> {x, y} end)
                |> MapSet.new
                |> MapSet.size
              # IO.inspect({starting, res}, label: "done")
              res
            end)
              |> Enum.max
          end)
        end)

        part2 = Task.await_many(tasks, 9_999_999_999)
          |> Enum.max
        IO.puts("Part 1: #{part1}")
        IO.puts("Part 2: #{part2}")
        {part1, part2}
      false ->
        IO.puts("Part 1: #{part1}")
        {part1, nil}
    end
  end
end

:timer.tc(fn -> Day16.solve(false, true) end, [])
  |> then(fn {t, r} -> {t/(1_000_000), r} end)
  |> IO.inspect(label: "Total time")
