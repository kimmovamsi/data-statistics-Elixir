defmodule Runner do
    def main do
        file = File.open!("out.convote", [:read])
        reader(file)
    end

    def reader(reader_file) do
         page = String.split(IO.read(reader_file, :all), "\n")
         populate(page, %{})
    end

    def populate([], map) do
        map
    end

    def populate([head | tail], map) do
        items = String.split(head, " ") |> Enum.slice(0,2)
        key = List.first(items) |> String.to_integer
        value = List.last(items) |> String.to_integer
        populate(tail, check_nil(map, key, value))
    end

    def check_nil(map, key, value) do
        if Map.get(map, key) != nil do
            in_map(key, value, map)
        else
            not_in_map(key, value, map)
        end
    end

    def in_map(key, value, map) do
        Map.replace!(map, key, populate_set(map[key], value))
    end

    def not_in_map(key, value, map) do
        Map.put_new(map, key, populate_set(MapSet.new(), value))
    end

    def populate_set(set, add_this) do
        MapSet.union(set, MapSet.put(MapSet.new(), add_this))
    end


end
