using Random

"""
    Space

A space is a tuple of a data type and a size.
The space also has a low and high bound for the values.
If the space is discrete, the values are integers.
If the space is continuous, the values are floats.

This implementation is inspired by the Space class from the elements package:
https://github.com/danijar/elements/blob/main/elements/space.py

The Julia implementation follows similar principles but is adapted for Julia's type system
and conventions while maintaining the core functionality of defining and sampling from
bounded spaces of different data types and dimensions.
"""
struct Space
    dtype::DataType
    size::Tuple
    low::Union{Nothing, AbstractArray}
    high::Union{Nothing, AbstractArray}
    discrete::Bool
end

@doc """
    Space(dtype::DataType, size=(); low=nothing, high=nothing)

Create a Space object that defines the shape and bounds of possible values.

# Arguments
- `dtype::DataType`: The data type of the space (e.g., Float64, Int64, Bool)
- `size`: Dimensions of the space as a tuple or single integer. Default is () for scalar values
- `low`: Lower bound(s) of the space. Can be a scalar or array matching size. If not provided, inferred from dtype
- `high`: Upper bound(s) of the space. Can be a scalar or array matching size. If not provided, inferred from dtype

# Examples
```julia
# Create a 2D continuous space of Float64 values between -1 and 1
box_2d = Space(Float64, (2,), low=-1.0, high=1.0)

# Create a discrete space of 3 integers from 0 to 10
discrete_space = Space(Int64, 3, low=0, high=10)

# Create a boolean space of shape (2,2)
bool_grid = Space(Bool, (2,2))

# Create a 3D image space of UInt8 values between 0 and 255
image_space = Space(UInt8, (64, 64, 1))

# Create an unbounded continuous scalar space
continuous_scalar = Space(Float64)
```

The space can be used for sampling values (`sample(space)`) and checking if values 
are within bounds (`value in space`).
"""
function Space(dtype::DataType, size=(); low=nothing, high=nothing)
    # Convert single integer size to tuple
    size = isa(size, Integer) ? (size,) : Tuple(size)
    
    # Infer low and high bounds
    low = _infer_low(dtype, size, low, high)
    high = _infer_high(dtype, size, low, high)
    
    # Check if space is discrete
    discrete = dtype <: Integer || dtype == Bool
    
    Space(dtype, size, low, high, discrete)
end

"""
    _infer_low(dtype::DataType, size::Tuple, low, high)

Infer the low bound for the space.
"""
function _infer_low(dtype::DataType, size::Tuple, low, high)
    if low !== nothing
        return broadcast_to(low, size)  # if user provides a scalar, use it
    elseif dtype <: AbstractFloat
        return fill(-Inf, size)
    elseif dtype <: Integer
        return fill(typemin(dtype), size)
    elseif dtype == Bool
        return fill(false, size)
    else
        throw(ArgumentError("Cannot infer low bound from size and dtype."))
    end
end

"""
    _infer_high(dtype::DataType, size::Tuple, low, high)

Infer the high bound for the space.
"""
function _infer_high(dtype::DataType, size::Tuple, low, high)
    if high !== nothing
        return broadcast_to(high, size)
    elseif dtype <: AbstractFloat
        return fill(Inf, size)
    elseif dtype <: Integer
        return fill(typemax(dtype), size)
    elseif dtype == Bool
        return fill(true, size)
    else
        throw(ArgumentError("Cannot infer high bound from size and dtype."))
    end
end

"""
    broadcast_to(value, size::Tuple)

Broadcast a value to a given size.
"""
function broadcast_to(value, size::Tuple)
    try
        return fill(value, size)
    catch
        throw(ArgumentError("Cannot broadcast $value to size $size"))
    end
end

"""
    in(value, space::Space)

Check if a value is in a space.
"""
function Base.in(value, space::Space)
    try
        value_array = convert(Array{space.dtype}, value)
        return size(value_array) == space.size &&
               all(value_array .<= space.high) &&
               all(value_array .>= space.low)
    catch
        return false
    end
end

"""
    sample(space::Space)

Sample a value from a space.
"""
function sample(space::Space)
    if space.dtype <: AbstractFloat
        # Sample from uniform distribution between low and high
        return rand(space.size) .* (space.high .- space.low) .+ space.low
    elseif space.dtype <: Integer
        # Sample integers uniformly between low and high
        if isempty(space.size)
            # Handle scalar case by extracting bounds
            return rand(space.low[]:space.high[])
        else
            # Handle array case by sampling from each range element-wise
            return rand.(UnitRange.(space.low, space.high))
        end
    elseif space.dtype == Bool
        return rand(Bool, space.size)
    else
        throw(ArgumentError("Sampling not implemented for type $(space.dtype)"))
    end
end

"""
    show(io::IO, space::Space)

Pretty print a space.
"""
function Base.show(io::IO, space::Space)
    if isempty(space.size)
        # Display scalar bounds directly for 0-dimensional spaces
        low_val = isnothing(space.low) ? nothing : space.low[]
        high_val = isnothing(space.high) ? nothing : space.high[]
    else
        # Display min/max for array bounds
        low_val = isnothing(space.low) ? nothing : minimum(space.low)
        high_val = isnothing(space.high) ? nothing : maximum(space.high)
    end
    print(io, "Space($(space.dtype), size=$(space.size), low=$(low_val), high=$(high_val))")
end

"""
    getproperty(space::Space, sym::Symbol)

Overload property access for Space.
If the space is scalar (size is empty) and the property is :low or :high,
return the scalar value directly instead of the 0-dimensional array.
"""
function Base.getproperty(space::Space, sym::Symbol)
    if (sym === :low || sym === :high) && isempty(space.size)
        val = getfield(space, sym)
        # Return the scalar value if it's not nothing
        return isnothing(val) ? nothing : val[]
    else
        # Default behavior for other properties or non-scalar spaces
        return getfield(space, sym)
    end
end



