defmodule Day1 do
  def get_input(test \\ true) do
    filename = case test do
      false -> "input/1.txt"
      true -> "test_input/1.2.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
  end

  @num_strs %{
    "one" => 1, "two" => 2, "three" => 3, "four" => 4, "five" => 5,
    "six" => 6, "seven" => 7, "eight" => 8, "nine" => 9,
    "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5,
    "6" => 6, "7" => 7, "8" => 8, "9" => 9,
  }

  def extract_nums(l) do
    nums = l |> String.replace(~r/[^\d]/, "") |> String.graphemes
    first = hd(nums)
    last = nums |> Enum.reverse |> hd
    Integer.parse(first <> last) |> elem(0)
  end

  def get_val(l) do
    indicies = Map.keys(@num_strs) |> Enum.map(fn s -> {s, Regex.scan(Regex.compile(s) |> elem(1), l, return: :index)} end)
      |> Enum.filter(fn {_, v} -> length(v) > 0 end)
      |> Enum.map(fn {k, v} -> {k, List.flatten(v)} end)

    first_key = indicies |> Enum.min_by(fn {_, v} -> hd(v) end) |> elem(0)
    first = Map.get(@num_strs, first_key)
    last_key = indicies |> Enum.max_by(fn {_, v} -> hd(Enum.reverse(v)) end) |> elem(0)
    last = Map.get(@num_strs, last_key)

    first * 10 + last
  end

  def extract_nums_strings(l) do
    get_val(l)
  end

  def solve(test \\ false) do
    input = get_input(test)
    # part1 = input
    #   |> Enum.map(fn l -> extract_nums(l) end)
    #   |> Enum.sum
    part1 = nil
    part2 = input
      |> Enum.map(fn l -> extract_nums_strings(l) end)
      |> IO.inspect
      |> Enum.sum

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day1.solve()
