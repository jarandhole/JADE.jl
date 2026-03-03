struct WindStation
    node::Symbol
    capacity::Float64
    #omcost::Float64
end


function getwinds(file::String, nodes::Vector{Symbol})
    wind_stations = Dict{Symbol,WindStation}()
    line_number = 0
    parsefile(file, true) do items
        line_number += 1
        if line_number == 1
            return  # Skip the first line
        end
        station = str2sym(items[1])
        if haskey(wind_stations, station)
            error("Wind Station ($station) already given.")
        end
        if str2sym(items[2]) in nodes
            return wind_stations[station] = WindStation(
                str2sym(items[2]),          # node
                parse(Float64, items[3]),   # capacity
                #parse(Float64, items[6]),   # O&M cost
            )
        else
            error("Node " * items[2] * " for generator " * items[1] * " not found")
        end
    end
    return wind_stations
end

#JHO: hard coded this to get rid of JLD2 dependence, but now the dictionary is containing strings, could change here to make week and block Int and value Float64
function getwindrepresentation(filename::String)
    data = readdlm(filename, ',', String)
    wind_representation = Dict{Any,Any}()

    for i in 2:size(data, 1)
    
        node = data[i, 1]
        week = parse(Int, data[i, 2])
        block = data[i, 3]
        value = parse(Float64, data[i, 4])

        if haskey(wind_representation, node)
            subdict = wind_representation[node]
        else
            subdict = Dict{Int,Dict{String,Float64}}()
            wind_representation[node] = subdict
        end

        if haskey(subdict, week)
            subsubdict = subdict[week]
        else
            subsubdict = Dict{String,Float64}()
            subdict[week] = subsubdict
        end
        subsubdict[block] = value
    end
    return wind_representation
end

