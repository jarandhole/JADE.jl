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
    wind_representation = Dict{Symbol, Dict{Tuple{Int, Int, Symbol},Float64}}()
    df = CSV.read(filename, DataFrame)

    for row in eachrow(df)
        station = Symbol(row.STATION)
        year = row.YEAR
        week = row.WEEK

        # Ensure the station key exists in the dictionary
        if !haskey(wind_representation, station)
            wind_representation[station] = Dict{Tuple{Int, Int, Symbol}, Float64}()
        end

        # Add block values to the dictionary
        for block in [:B1, :B2, :B3, :B4, :B5]
            wind_representation[station][(year, week, block)] = row[block]
        end
    end
    return wind_representation
end
    