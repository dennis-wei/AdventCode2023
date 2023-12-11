defmodule Day10 do
  def get_input(test \\ false) do
    filename = case test do
      false -> "input/10.txt"
      true -> "test_input/10.6.txt"
    end
    Input
      # .ints(filename)
      # .line_tokens(filename)
      .lines(filename)
      # .line_of_ints(filename)
      # .ints_in_lines(filename)
  end

  def make_graph_pt1(grid, s_repl \\ "F") do
    Enum.reduce(grid, {Graph.new, nil}, fn {{x, y}, val}, {graph, start} ->
      uval = case val do
        "S" -> s_repl
        _ -> val
      end
      ustart = case val do
        "S" -> {x, y}
        _ -> start
      end
      right = MapSet.new(["7", "-", "J"])
      left = MapSet.new(["F", "L", "-"])
      down = MapSet.new(["J", "L", "|"])
      up = MapSet.new(["F", "7", "|"])
      to_test = case uval do
        "." -> []
        "F" -> [{{x + 1, y}, right}, {{x, y + 1}, down}]
        "7" -> [{{x - 1, y}, left}, {{x, y + 1}, down}]
        "J" -> [{{x - 1, y}, left}, {{x, y - 1}, up}]
        "L" -> [{{x + 1, y}, right}, {{x, y - 1}, up}]
        "-" -> [{{x + 1, y}, right}, {{x - 1, y}, left}]
        "|" -> [{{x, y + 1}, down}, {{x, y - 1}, up}]
        _ -> raise "Unknown val: #{val}"
      end
      valid_edges = Enum.filter(to_test, fn {{nx, ny}, valid} -> MapSet.member?(valid, Map.get(grid, {nx, ny}, ".")) end)
      edges = Enum.map(valid_edges, fn {{nx, ny}, _} -> {{x, y}, {nx, ny}} end)
      {Graph.add_edges(graph, edges), ustart}
    end)
  end

  def part1_bfs(graph, start) do
    init_seen = MapSet.put(MapSet.new, start)
    Enum.reduce_while(0..Graph.num_vertices(graph), {:queue.in({start, 0}, :queue.new), init_seen}, fn _i, {q, seen} ->
      {res, popped_q} = :queue.out(q)
      case res do
        :empty -> {:halt, seen}
        {:value, {p, d}} ->
          neighbors = Graph.neighbors(graph, p)
          unseen = Enum.filter(neighbors, fn n -> !MapSet.member?(seen, n) end)
          uqueue = Enum.reduce(unseen, popped_q, fn n, acc ->
            :queue.in({n, d + 1}, acc)
          end)
          useen = Enum.reduce(unseen, seen, fn n, acc ->
            MapSet.put(acc, n)
          end)
          {:cont, {uqueue, useen}}
      end
    end)
  end

  def make_graph_pt2(grid, loop, s_repl \\ "F") do
    max_x = Enum.map(grid, fn {{x, _y}, _v} -> x end)
      |> Enum.max
    max_y = Enum.map(grid, fn {{_x, y}, _v} -> y end)
      |> Enum.max
    perim_edges = [{{-1, -1}, {-1, 0}}, {{-1, -1}, {0, -1}},
      {{max_x + 1, -1}, {max_x + 1, 0}}, {{max_x + 1, -1}, {max_x, -1}},
      {{-1, max_y + 1}, {-1, max_y}}, {{-1, max_y + 1}, {0, max_y + 1}},
      {{max_x + 1, max_y + 1}, {max_x + 1, max_y}}, {{max_x + 1, max_y + 1}, {max_x, max_y + 1}}]
    base_graph = Graph.new
      |> Graph.add_edges(perim_edges)
    Enum.reduce(grid, base_graph, fn {{x, y}, val}, graph ->
      uval = case val do
        "S" -> s_repl
        _ -> val
      end
      forward_edges = cond do
        uval == "." or !MapSet.member?(loop, {x, y}) ->
          [{{x, y}, {x + 1, y}}, {{x, y}, {x, y + 1}},
            {{x + 1, y}, {x + 1, y + 1}}, {{x, y + 1}, {x + 1, y + 1}},
            {{x, y}, {x + 1, y + 1}}, {{x + 1, y}, {x, y + 1}},
            {{x, y}, {x + 0.5, y + 0.5}}, {{x + 1, y}, {x + 0.5, y + 0.5}},
            {{x, y + 1}, {x + 0.5, y + 0.5}}, {{x + 1, y + 1}, {x + 0.5, y + 0.5}}]
        uval == "F" -> [{{x, y}, {x + 1, y}}, {{x, y}, {x, y + 1}}]
        uval == "7" -> [{{x, y}, {x + 1, y}}, {{x + 1, y}, {x + 1, y + 1}}]
        uval == "J" -> [{{x + 1, y}, {x + 1, y + 1}}, {{x, y + 1}, {x + 1, y + 1}}]
        uval == "L" -> [{{x, y}, {x, y + 1}}, {{x, y + 1}, {x + 1, y + 1}}]
        uval == "|" -> [{{x, y}, {x, y + 1}}, {{x + 1, y}, {x + 1, y + 1}}]
        uval == "-" -> [{{x, y}, {x + 1, y}}, {{x, y + 1}, {x + 1, y + 1}}]
        true -> raise "Unknown symbol: #{uval}"
      end
      reversed_edges = Enum.map(forward_edges, fn {p1, p2} -> {p2, p1} end)
      all_edges = forward_edges ++ reversed_edges
      Graph.add_edges(graph, all_edges)
    end)
  end

  def part2(graph) do
    reachable = Graph.reachable(graph, [{0, 0}])
      |> Enum.filter(fn {x, y} -> x - trunc(x) == 0.5 and y - trunc(y) == 0.5 end)
      |> MapSet.new
    all = Graph.vertices(graph)
      |> Enum.filter(fn {x, y} -> x - trunc(x) == 0.5 and y - trunc(y) == 0.5 end)
      |> MapSet.new
    MapSet.difference(all, reachable)
      |> Enum.count
  end

  def pad_input(lines) do
    num_col = Enum.at(lines, 0)
      |> String.length
    vpad = String.duplicate(".", num_col + 2)
    [vpad | Enum.map(lines, fn line -> ".#{line}." end)] ++ [vpad]
  end

  def solve(test \\ false) do
    input = get_input(test)
      |> pad_input
      |> Enum.map(fn line -> String.graphemes(line) end)
      |> Grid.make_grid(true)
    {graph1, start} = make_graph_pt1(input, "-")
    Graph.neighbors(graph1, start)
    loop = part1_bfs(graph1, start)
    part1 = div(Enum.count(loop), 2)

    graph2 = make_graph_pt2(input, loop, "-")
    part2 = part2(graph2)
    IO.puts("Part 1: #{part1}")
    IO.puts("Part 2: #{part2}")
  end
end

Day10.solve()
