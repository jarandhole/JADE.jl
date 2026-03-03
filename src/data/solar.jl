struct SolarStation
    node::Symbol
    capacity::Float64
    #omcost::Float64
end



function getsolars(file::String, nodes::Vector{Symbol})
    solar_stations = Dict{Symbol,SolarStation}()
    parsefile(file, true) do items
        line_number += 1
        if line_number == 1
            return  # Skip the first line
        end
        station = str2sym(items[1])
        if haskey(solar_stations, station)
            error("Solar Station ($station) already given.")
        end
        if str2sym(items[2]) in nodes
            return solar_stations[station] = SolarStation(
                str2sym(items[2]),          # node
                parse(Float64, items[3]),   # capacity
                #parse(Float64, items[6]),   # O&M cost
            )
        else
            error("Node " * items[2] * " for generator " * items[1] * " not found")
        end
    end
    return solar_stations
end

#JHO: hard coded this to get rid of JLD2 dependence, but now the dictionary is containing strings, could change here to make week and block Int and value Float64
function getsolarrepresentation(filename::String)
    data = readdlm(filename, ',', String)
    solar_representation = Dict{Any,Any}()

    for i in 2:size(data, 1)
    
        node = data[i, 1]
        week = parse(Int, data[i, 2])
        block = data[i, 3]
        value = parse(Float64, data[i, 4])

        if haskey(solar_representation, node)
            subdict = solar_representation[node]
        else
            subdict = Dict{Int,Dict{String,Float64}}()
            solar_representation[node] = subdict
        end

        if haskey(subdict, week)
            subsubdict = subdict[week]
        else
            subsubdict = Dict{String,Float64}()
            subdict[week] = subsubdict
        end
        subsubdict[block] = value
    end
    return solar_representation
end
