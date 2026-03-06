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
    wind_representation = Dict{Symbol, Dict{Tuple{Int16, Int16, Symbol}, Float64}}()

    # Open the file and read it line by line
    open(filename, "r") do file
        # Read the header line to get the column names
        header = split(chomp(readline(file)), ",")
        block_columns = filter(x -> startswith(x, "B"), header)

        # Read each subsequent line
        for line in eachline(file)
            row = split(chomp(line), ",")
            station = Symbol(row[1])
            year = parse(Int, row[2])
            week = parse(Int, row[3])

            # Ensure the station key exists in the dictionary
            if !haskey(wind_representation, station)
                wind_representation[station] = Dict{Tuple{Int16, Int16, Symbol}, Float64}()
            end

            # Add block values to the dictionary
            for (i, block) in enumerate(block_columns)
                block_symbol = Symbol(block)
                wind_representation[station][(year, week, block_symbol)] = parse(Float64, row[3 + i])
            end
        end
    end

    return wind_representation
end
