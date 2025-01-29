# Tools.jl

A collection of utility functions for Julia programming.

## Installation

Since this package is not registered in Julia's General Registry, you can install it directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/simonedambrogio/Tools.jl")
```

Or in Julia's pkg mode (press `]`):
```julia
] add https://github.com/simonedambrogio/Tools.jl
```

## Features

### Space

A flexible space definition system for defining bounded spaces of different data types and dimensions. Inspired by the [elements package](https://github.com/danijar/elements/blob/main/elements/space.py).

```julia
using Tools

# Create a 2D continuous space of Float64 values between -1 and 1
box_2d = Space(Float64, (2,), low=-1.0, high=1.0)

# Create a discrete space of 3 integers from 0 to 10
discrete_space = Space(Int64, 3, low=0, high=10)

# Create a boolean space of shape (2,2)
bool_grid = Space(Bool, (2,2))

# Sample from the space
sample(box_2d)  # Returns a random point in the space
value in box_2d  # Check if a value is within the space bounds
```

### Symbolize

A utility for converting strings and dictionary keys/values to symbols, particularly useful when working with configuration files.

```julia
using Tools

# Convert a string to symbol
symbolize("hello")  # Returns :hello

# Convert nested dictionary keys and string values to symbols
config = Dict(
    "defaults" => Dict(
        "env" => Dict(
            "name" => "pong",
            "size" => [84, 84]
        )
    )
)

symbolized = symbolize(config)
# Returns Dict(
#     :defaults => Dict(
#         :env => Dict(
#             :name => :pong,
#             :size => [84, 84]  # Non-string values remain unchanged
#         )
#     )
# )
```
