module Aerodynamics

using CSV
using DataFrames
using Interpolations
using Revise

aero_data_path = joinpath(@__DIR__, "..", "data", "aero_data.csv")

function import_aero_data(aero_data_path::String) 
    
    if !isnothing(aero_data_path) && isfile(aero_data_path)
        try
            aero_data_set = CSV.read(aero_data_path, DataFrame)
            return aero_data_set
        catch e
            println(stderr, "Error while importing file '$aero_data_path': ", e)
            return nothing
        end
    else 
        println(stderr, "Invalid path or file does not exist: $aero_data_path")
        return nothing
    end

end

function interpolate_aero_data(known_value::Number, known_param::Symbol, unknown_param::Symbol)

    aero_data_set = import_aero_data(aero_data_path)

    #To validate aero_data.csv
    if isnothing(aero_data_set) || isempty(aero_data_set)
        println(stderr, "Invalid or empty aero_data_set: $aero_data_set")
        return nothing
    end

    #To check if the parameter passed is present in aero_data.csv
    aero_data_in_symbol = Symbol.(names(aero_data_set))
    if !(known_param in aero_data_in_symbol) || !(unknown_param in aero_data_in_symbol)
        println(stderr,  "Parameter $known_param or $unknown_param not found in dataset")
        return nothing
    end

    x = aero_data_set[!, known_param]
    y = aero_data_set[!, unknown_param]
    min_x = minimum(x)
    max_x = maximum(x)

    #To handle out-of-bounds known_value
    if (known_value < min_x || known_value > max_x)
        println(stderr,  "Known value $known_value is out of bounds [$min_x, $max_x]")
        return nothing
    end

    try
        itp = LinearInterpolation(x, y)
        interpolated_value = itp(known_value)
        return interpolated_value
    catch e
        println(stderr, "Error during interpolation: $e")
        return nothing
    end

end


end