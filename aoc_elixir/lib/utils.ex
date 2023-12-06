defmodule Utils do
  def get_all_nums(s) do
    Regex.scan(~r/\d+/, s)
      |> List.flatten
      |> Enum.map(&String.to_integer/1)
  end
end
