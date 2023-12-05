defmodule Day5 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/5.txt"
      true -> "test_input/5.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename, "\n", "\n\n")
      # .lines(filename)
      # .line_of_ints(filename)
  end

  def get_all_nums(s) do
    Regex.scan(~r/\d+/, s)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
  end

  def apply_translations(s, translations) do
    Enum.reduce_while(translations, s, fn [destination, source, range], _acc ->
      cond do
        source <= s and s < source + range ->
          {:halt, destination + (s - source)}
        true -> {:cont, s}
      end
    end)
  end

  def run(seeds, translations) do
    Enum.reduce(translations, seeds, fn translation, acc ->
      Enum.map(acc, fn seed -> apply_translations(seed, translation) end)
    end)
  end

  def randomly_choose(start, range) do
    0..trunc(:math.sqrt(range)) |> Enum.map(fn _ -> start + :rand.uniform(range) end)
  end

  def try_random(p1_input, translations) do
    random_input = p1_input
      |> Enum.chunk_every(2)
      |> Enum.map(fn [s1, r1] -> randomly_choose(s1, r1) end)
      |> List.flatten
      |> Enum.sort

    random_run_outcomes = run(random_input, translations)
    zipped = Enum.zip(random_input, random_run_outcomes)
    {best_guess, _} = Enum.min_by(zipped, fn {_seed, outcome} -> outcome end)
    guess_range = p1_input
      |> Enum.chunk_every(2)
      |> Enum.map(fn [_s1, r1] -> r1 end)
      |> Enum.max
      |> :math.sqrt
      |> trunc
    run_input = Enum.to_list(best_guess-guess_range..best_guess+guess_range)
    run(run_input, translations)
      |> Enum.min
  end

  def solve(test \\ false) do
    input = get_input(test)
    p1_input = input |> Enum.at(0) |> Enum.at(0) |> get_all_nums
    translations = Enum.map(tl(input), fn t -> tl(t) |> Enum.map(fn r -> get_all_nums(r) end) end)
    part1 = run(p1_input, translations)
      |> Enum.min

    part2 = Enum.map(0..5, fn _ -> try_random(p1_input, translations) end)
      |> Enum.min

    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day5.solve()
