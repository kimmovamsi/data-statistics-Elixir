defmodule Runner do

    def main do
        reader(File.open!("out.convote", [:read]))
    end

    def reader(reader_file) do
         populate(String.split(IO.read(reader_file, :all), "\n"), %{})
    end

    def populate([], map) do
        map
    end

    def populate([head | tail], map) do
        items = String.split(head, " ") |> Enum.slice(0,2)
        key = List.first(items) |> String.to_integer
        value = List.last(items) |> String.to_integer
        populate(tail, check_nil_and_update(map, key, value))
    end

    def check_nil_and_update(map, key, value) do
        if Map.get(map, key) != nil do
            Map.replace!(map, key, populate_set(map[key], value))
        else
            Map.put_new(map, key, populate_set(MapSet.new(), value))
        end
    end

    def populate_set(set, add_this) do
        MapSet.union(set, MapSet.put(MapSet.new(), add_this))
    end

end
