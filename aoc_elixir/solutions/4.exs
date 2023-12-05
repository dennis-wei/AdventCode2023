defmodule Day4 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/4.txt"
      true -> "test_input/4.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end


  def parse_input(line) do
    [game_number, game] = String.split(line, ": ")
    [wins, attempts] = String.split(game, "| ")
    game_number = String.to_integer(String.split(game_number)|> Enum.at(1))

    win_nums = Regex.scan(~r/\d+/, wins)
      |> Enum.map(fn [x] -> String.to_integer(x) end)
    attempt_nums = Regex.scan(~r/\d+/, attempts)
      |> Enum.map(fn [x] -> String.to_integer(x) end)
    {game_number, win_nums, attempt_nums}
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> Enum.map(&parse_input/1)
    initial_wins = input
      |> Enum.map(fn {gn, wn, an} -> {gn, MapSet.new(wn), MapSet.new(an)} end)
      |> Enum.map(fn {gn, wn, an} -> {gn, MapSet.intersection(wn, an)} end)
      |> Enum.map(fn {gn, overlap} -> {gn, MapSet.size(overlap)} end)

    part1 = initial_wins
      |> Enum.map(fn {_, wins} -> wins end)
      |> Enum.filter(fn x -> x > 0 end)
      |> Enum.map(fn x -> :math.pow(2, x - 1) end)
      |> Enum.sum
    part2 = Enum.reduce(initial_wins, %{}, fn {gn, wins}, acc ->
      case wins do
        0 -> Map.update(acc, gn, 1, fn k -> k + 1 end)
        _ ->
          updated = Map.update(acc, gn, 1, fn k -> k + 1 end)
          num_copies = Map.get(updated, gn)
          1..wins
            |> Enum.map(fn x -> gn + x end)
            |> Enum.reduce(updated, fn x, iacc ->
              Map.update(iacc, x, num_copies, fn k -> k + num_copies end) end)
      end
    end)
      |> Map.values
      |> Enum.sum
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day4.solve()
