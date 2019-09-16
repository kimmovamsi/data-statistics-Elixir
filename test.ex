defmodule Runner do

    def main do
        sw_start = System.monotonic_time(:second)
        filename = "out.stackexchange-stackoverflow"
        IO.inspect "File Name -> #{filename}"
        {dict, edges} = populate(String.split(IO.read(File.open!(filename, [:read]), :all), "\n"), %{}, [])
        counter(dict, edges) |> IO.inspect
        sw_end = System.monotonic_time(:second)
        IO.puts "Time took -> #{sw_end - sw_start}"
    end

    def counter(map, edges) do
        for_each(edges, map, [0,0,0,0])
    end

    def for_each([], _, result) do
        result
    end

    def for_each([head | tail], map, result) do
        head = Tuple.to_list(head)
        a = hd(head)
        b = tl(head) |> hd
        a_outs = Map.fetch!(map, a)
        if Map.has_key?(map, b) and MapSet.member?(a_outs, b) do
            b_outs = Map.fetch!(map, b)
            if MapSet.member?(b_outs, a) == false do
                b_outs_to_list = MapSet.to_list(b_outs)
                for_each(tail, map, type(b_outs_to_list, map, a, a_outs, b, result))
            else
                for_each(tail, map, result)
            end 
        else
            for_each(tail, map, result)
        end
    end

    def type([], _, _, _,_, return) do
        return
    end

    def type([p_c | tail], map, a, a_outs,b, return) do
        if Map.has_key?(map, p_c) do
            p_c_outs = Map.fetch!(map, p_c)
            if MapSet.member?(p_c_outs, b) == false do
                cond do
                    MapSet.member?(a_outs, p_c) == false and MapSet.member?(p_c_outs, a) -> 
                        type(tail, map, a, a_outs, b, Enum.zip(return, [1,0,0,0]) |> Enum.map(fn each -> Tuple.to_list(each) |> Enum.sum end))
                    MapSet.member?(a_outs, p_c) and MapSet.member?(p_c_outs, a) == false -> 
                        type(tail, map, a, a_outs, b, Enum.zip(return, [0,1,0,0]) |> Enum.map(fn each -> Tuple.to_list(each) |> Enum.sum end))
                    MapSet.member?(a_outs, p_c) and MapSet.member?(p_c_outs, a) -> 
                        type(tail, map, a, a_outs, b, Enum.zip(return, [0,0,1,0]) |> Enum.map(fn each -> Tuple.to_list(each) |> Enum.sum end))
                    MapSet.member?(a_outs, p_c) == false and MapSet.member?(p_c_outs, a) == false -> 
                        type(tail, map, a, a_outs, b, Enum.zip(return, [0,0,0,1]) |> Enum.map(fn each -> Tuple.to_list(each) |> Enum.sum end))
                end
            else
                type(tail, map, a, a_outs,b, return)
            end
        else
            if MapSet.member?(a_outs, p_c) do
                type(tail, map, a, a_outs, b, Enum.zip(return, [0,1,0,0]) |> Enum.map(fn each -> Tuple.to_list(each) |> Enum.sum end))
            else
                type(tail, map, a, a_outs, b, Enum.zip(return, [0,0,0,1]) |> Enum.map(fn each -> Tuple.to_list(each) |> Enum.sum end))
            end
        end
    end

    def populate([], map, listo) do
        {map, listo}
    end

    def populate([head | tail], map, listo) do
        items = String.split(head, " ") |> Enum.slice(0,2)
        key = hd(items) |> String.to_integer
        value = tl(items) |> hd |> String.to_integer
        populate(tail, check_nil_and_update(map, key, value), [{key, value} | listo])
    end

    def check_nil_and_update(map, key, value) do
        if Map.get(map, key) != nil do
            Map.replace!(map, key, populate_set(Map.fetch!(map, key), value))
        else
            Map.put_new(map, key, populate_set(MapSet.new(), value))
        end
    end

    def populate_set(set, add_this) do
        MapSet.union(set, MapSet.put(MapSet.new(), add_this))
    end

end