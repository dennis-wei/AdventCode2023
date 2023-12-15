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


  def run({str, pattern}, curr_block) do
    key = {str, pattern, curr_block}
    res = cond do
      str == [] and String.length(curr_block) == 0 and pattern == [] -> 1
      str == [] and String.length(curr_block) != 0 and pattern == [] -> 0
      str == [] and String.length(curr_block) == hd(pattern) -> 1
      str == [] and String.length(curr_block) != hd(pattern) -> 0
      Enum.count(str) + String.length(curr_block) < Enum.sum(pattern) -> 0
      Enum.count(pattern) > 0 and String.length(curr_block) > hd(pattern) -> 0
      true ->
        case Process.get(key) do
          :nil ->
            case hd(str) do
              "." ->
                cond do
                  String.length(curr_block) > 0 and pattern == [] -> 0
                  String.length(curr_block) > 0 and String.length(curr_block) != hd(pattern) -> 0
                  String.length(curr_block) > 0 and String.length(curr_block) == hd(pattern) ->
                    run({tl(str), tl(pattern)}, "")
                  String.length(curr_block) == 0 -> run({tl(str), pattern}, "")
                end
              "#" -> run({tl(str), pattern}, "#{curr_block}#")
              "?" ->
                r1 = run({["." | tl(str)], pattern}, curr_block)
                r2 = run({["#" | tl(str)], pattern}, curr_block)
                r1 + r2
            end
          n -> n
        end
    end
    Process.put(key, res)
    res
  end

  def solve(test \\ false) do
    base_input = get_input(test)
    part1_input = base_input
      |> Enum.map(fn [str, pattern] -> {String.graphemes(str), Utils.get_all_nums(pattern)} end)
    part1 = part1_input
      |> Enum.reduce(0, fn line, acc ->
        acc + run(line, "")
      end)
    part2 = base_input
      |> Enum.map(fn line -> unfold(line) end)
      |> Enum.map(fn [str, pattern] -> {String.graphemes(str), Utils.get_all_nums(pattern)} end)
      |> Enum.map(fn line ->
        res = run(line, "")
        res
      end)
      |> Enum.sum
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day12.solve()
