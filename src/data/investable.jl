mutable struct Investable
    fuel::Symbol
    heat_rate::Float64
    min_investment::Float64
    max_investment::Float64
    capex::Float64
    opex::Float64
    lifespan_years::Int
    index::Int
end

function initialiseinvestables(
    investables_filename::String,
    length_reservoirs::Int,

)
    investables = Dict{Symbol,Investable}()
    for row in CSV.Rows(
        investables_filename;
        missingstring = "NA",
        stripwhitespace = true,
        comment = "%",
    )
#= 
        row = _validate_and_strip_trailing_comment(
            row,
            [
                :ID,
                :FUEL,
                :HEAT_RATE,
                :min_investment,
                :max_investment,
                :capex,
                :opex,
                :lifespan_years,
            ],
        )
 =# 
        investable = str2sym(row[:ID])  # Access fields using `row[:FieldName]`
        if haskey(investables, investable)
            error("Investable asset $(investable) given twice.")
        end
        investables[investable] = Investable(
            str2sym(row[:FUEL]),
            parse(Float64, row[:HEAT_RATE]),
            parse(Float64, row[:min_investment]),
            parse(Float64, row[:max_investment]),
            parse(Float64, row[:capex]),
            parse(Float64, row[:opex]),
            parse(Int, row[:lifespan_years]),
            length_reservoirs + length(investables) + 1,
        )
    end
    return investables
end