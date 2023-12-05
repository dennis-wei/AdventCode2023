defmodule Day2 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/2.txt"
      true -> "test_input/2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def parse_config(c) do
    color_pairs = String.split(c, ", ")
      |> Enum.map(fn x -> String.split(x, " ") end)
    color_pairs
      |> Enum.reduce(%{}, fn [num, color], map -> Map.put(map, color, String.to_integer(num)) end)
  end

  def parse_line(l) do
    [game_key, game_config] = String.split(l, ": ")
    game_num = String.split(game_key, " ") |> Enum.at(1) |> String.to_integer()
    configs = String.split(game_config, "; ")
      |> Enum.map(&parse_config/1)
    [max_blue, max_red, max_green] = ["blue", "red", "green"]
      |> Enum.map(fn x -> Enum.map(configs, fn c -> Map.get(c, x, 0) end) end)
      |> Enum.map(fn x -> Enum.max(x) end)
    {game_num, configs, max_blue, max_red, max_green}
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(fn x -> parse_line(x) end)
      # |> IO.inspect

    part1 = input
      |> Enum.filter(fn {_, _, mb, mr, mg} -> mb <= 14 and mr <= 12 and mg <= 13 end)
      |> Enum.map(fn {n, _, _, _, _} -> n end)
      |> Enum.sum
    part2 = input
      |> Enum.map(fn {_, _, mb, mr, mg} -> mb * mr * mg end)
      |> Enum.sum
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day2.solve()
