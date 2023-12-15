defmodule Day12 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/12.txt"
      true -> "test_input/12.1.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def unfold([line, pattern]) do
    full_line = cond do
      true -> List.duplicate(line, 5)
        |> Enum.join("?")
    end
    full_pattern = cond do
      true -> List.duplicate(pattern, 5)
        |> Enum.join(",")
    end

    [full_line, full_pattern]
  end


  def run_memoized({str, pattern}, curr_block, memo) do
    key = {str, pattern, curr_block}
    {res, umap} = cond do
      str == [] and String.length(curr_block) == 0 and pattern == [] -> {1, Map.put(memo, key, 1)}
      str == [] and String.length(curr_block) != 0 and pattern == [] -> {0, Map.put(memo, key, 0)}
      str == [] and String.length(curr_block) == hd(pattern) -> {1, Map.put(memo, key, 1)}
      str == [] and String.length(curr_block) != hd(pattern) -> {0, Map.put(memo, key, 0)}
      Enum.count(str) + String.length(curr_block) < Enum.sum(pattern) -> {0, Map.put(memo, key, 0)}
      Enum.count(pattern) > 0 and String.length(curr_block) > hd(pattern) -> {0, Map.put(memo, key, 0)}
      true ->
        case Map.get(memo, key) do
          :nil ->
            case hd(str) do
              "." ->
                cond do
                  String.length(curr_block) > 0 and pattern == [] -> {0, Map.put(memo, key, 0)}
                  String.length(curr_block) > 0 and String.length(curr_block) != hd(pattern) -> {0, Map.put(memo, key, 0)}
                  String.length(curr_block) > 0 and String.length(curr_block) == hd(pattern) ->
                    run_memoized({tl(str), tl(pattern)}, "", memo)
                  String.length(curr_block) == 0 -> run_memoized({tl(str), pattern}, "", memo)
                end
              "#" -> run_memoized({tl(str), pattern}, "#{curr_block}#", memo)
              "?" ->
                {r1, m1} = run_memoized({["." | tl(str)], pattern}, curr_block, memo)
                {r2, m2} = run_memoized({["#" | tl(str)], pattern}, curr_block, memo)
                {r1 + r2, Map.merge(m1, m2)}
            end
          n -> {n, memo}
        end
    end
    # {key, res} |> IO.inspect
    {res, Map.put(umap, key, res)}
  end

  def solve(test \\ false) do
    base_input = get_input(test)
    part1_input = base_input
      |> Enum.map(fn [str, pattern] -> {String.graphemes(str), Utils.get_all_nums(pattern)} end)
    {part1, cache} = part1_input
      |> Enum.reduce({0, %{}}, fn line, {racc, macc} ->
        {nr, nacc} = run_memoized(line, "", macc)
        {racc + nr, nacc}
      end)
    # part2 = base_input
    #   |> Enum.map(fn line -> unfold(line) end)
    #   |> Enum.map(fn [str, pattern] -> {String.graphemes(str), Utils.get_all_nums(pattern)} end)
    #   |> Enum.map(fn line ->
    #     IO.puts("Starting #{Enum.join(line |> elem(0), "")}")
    #     res = run_memoized(line, "", %{})
    #     IO.puts("Done with #{Enum.join(line |> elem(0), "")}")
    #     res
    #   end)
    #   |> Enum.map(fn {nr, _} -> nr end)
    #   |> Enum.sum
      # |> Enum.reduce({0, cache}, fn line, {racc, macc} ->
      #   IO.puts("Starting #{Enum.join(line |> elem(0), "")}")
      #   {nr, nacc} = run_memoized(line, "", macc)
      #   IO.puts("Done with #{Enum.join(line |> elem(0), "")}")
      #   Enum.count(nacc) |> IO.inspect(label: "Cache size")
      #   {racc + nr, nacc}
      # end)
      # |> elem(0)
    part2 = nil
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

:timer.tc(fn -> Day12.solve() end, [])
  |> elem(0)
  |> Kernel./(1_000_000)
  |> IO.inspect
