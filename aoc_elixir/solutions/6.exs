defmodule Day6 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/6.txt"
      true -> "test_input/6.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  def run(times, distance_records) do
    zipped = Enum.zip(times, distance_records)
    num_wins = zipped
      |> Enum.map(fn {t, d} ->
        Enum.reduce(0..t, 0, fn i, acc ->
          res = i * (t - i)
          cond do
            res > d -> acc + 1
            true -> acc
          end
        end)
      end)
    Enum.product(num_wins)
  end

  def combine(nums) do
    Enum.reduce(nums, "", fn n, acc ->
      "#{acc}#{n}"
    end)
      |> String.to_integer()
  end

  def solve(test \\ false) do
    input = get_input(test)
    times = input |> Enum.at(0) |> Utils.get_all_nums
    distance_records = input |> Enum.at(1) |> Utils.get_all_nums
    part1 = run(times, distance_records)

    combined_times = combine(times)
    combined_distnaces = combine(distance_records)

    part2 = run([combined_times], [combined_distnaces])
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day6.solve()
