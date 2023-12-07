defmodule Day7 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/7.txt"
      true -> "test_input/7.txt"
    end
    Input
      # .ints(filename)
      .line_tokens(filename)
      # .lines(filename)
      # .line_of_ints(filename)
  end

  @card_rank %{
    "1" => 1, "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6,
    "7" => 7, "8" => 8, "9" => 9, "T" => 10, "J" => 11,
    "Q" => 12, "K" => 13, "A" => 14
  }

  @type_rank %{
    :high_card => 1, :one_pair => 2, :two_pairs => 3,
    :three_kind => 4, :full_house => 5, :four_kind => 6,
    :five_kind => 7
  }

  def score(hand) do
    counts = hand |> String.graphemes |> Enum.reduce(%{}, fn c, acc ->
      Map.update(acc, c, 1, &(&1 + 1))
    end)
    {num_ones, popped} = Map.pop(counts, "1", 0)

    replaced_counts = cond do
      num_ones == 0 -> counts
      num_ones == 5 -> %{}
      true ->
        initial_max_count = Enum.max(Map.values(popped))
        Enum.reduce_while(popped, popped, fn {k, v}, acc ->
          cond do
            v == initial_max_count -> {:halt, Map.put(acc, k, v + num_ones)}
            true -> {:cont, acc}
          end
        end)
    end

    max_count = cond do
      Enum.count(replaced_counts) == 0 -> 5
      true -> Enum.max(Map.values(replaced_counts))
    end
    type_rank = cond do
      max_count == 5 -> :five_kind
      max_count == 4 -> :four_kind
      max_count == 3 && Enum.count(Map.values(replaced_counts), &(&1 == 2)) == 1 -> :full_house
      max_count == 3 -> :three_kind
      Enum.count(Map.values(replaced_counts), &(&1 == 2)) == 2 -> :two_pairs
      max_count == 2 -> :one_pair
      true -> :high_card
    end
      |> then(fn r -> Map.get(@type_rank, r) end)
    card_rank = hand |> String.graphemes |> Enum.map(fn c -> Map.get(@card_rank, c) end)
    [type_rank | card_rank]
      |> Enum.reduce(0, fn c, acc -> acc * 15 + c end)
  end

  def sort_hands(hands) do
    hands
      |> Enum.map(fn [hand, bid] -> {score(hand), hand, String.to_integer(bid)} end)
      |> Enum.sort(fn {s1, _, _}, {s2, _, _} -> s1 < s2 end)
  end

  def solve(test \\ false) do
    input = get_input(test)
    part1 = input
      |> sort_hands
      |> Enum.with_index(fn {_score, _hand, bid}, i -> bid * (i + 1) end)
      |> Enum.sum
    part2 = input
      |> Enum.map(fn [hand, bid] -> [String.replace(hand, "J", "1"), bid] end)
      |> sort_hands
      |> Enum.with_index(fn {_score, _hand, bid}, i -> bid * (i + 1) end)
      |> Enum.sum
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day7.solve()
