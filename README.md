# Tools.jl

A collection of utility functions designed to streamline research workflows in Julia.

## Overview

Tools.jl provides a set of helper functions commonly needed in research projects, with a focus on making configuration management and data processing more convenient.

## Features

### Configuration Management
- `symbolize`: Converts string keys and values in dictionaries to symbols, particularly useful when working with YAML config files and Julia's keyword arguments.

```julia
using Tools
using YAML

# Load config file
config = YAML.load_file("config.yaml")

# Convert string keys/values to symbols
symbolized_config = symbolize(config)
```

## Installation

Add the package to your project:
```julia
using Pkg
Pkg.develop(path="path/to/tools")
```

## Usage Example

Given a YAML configuration file:
```yaml
defaults:
  env:
    atari:
      name: "pong"
      repeat: 4
      size: [84, 84]
      actions: "all"
```

You can easily convert it to a symbol-based dictionary:
```julia
using Tools
using YAML

config = YAML.load_file("config.yaml")
symbolized = symbolize(config)
# Result: Dict(:defaults => Dict(:env => Dict(:atari => Dict(:name => :pong...))))
```

## Contributing

Feel free to open issues or submit pull requests with additional utilities that could benefit the research community.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 