@doc"""
symbolize.jl

This function converts strings and dictionary keys/values to symbols,
which is particularly useful for processing configuration files.

Example:
    Given a YAML config file with:
    ```yaml
    defaults:
      env:
        atari:
          name: "pong"
          repeat: 4
          size: [84, 84]
          actions: "all"
    ```

    Using symbolize:
    ```julia
    config = YAML.load_file("config.yaml")
    # config = Dict("defaults" => Dict("env" => Dict("atari" => Dict("name" => "pong"...))))
    
    symbolized = symbolize(config)
    # symbolized = Dict(:defaults => Dict(:env => Dict(:atari => Dict(:name => :pong...))))
    ```

This conversion is useful when working with Julia functions that expect symbols 
as keyword arguments or when matching against symbol-based patterns.
"""
function symbolize(x::String)
    Symbol(x)
end

function symbolize(d::Dict)
    Dict(k => symbolize(v) for (k, v) in d)
end

function symbolize(x)
    x  # return unchanged for other types
end 