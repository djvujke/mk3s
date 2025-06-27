#!/bin/bash

# Print Helper Functions
# Provides consistent output formatting across all scripts

# Custom print function
# Usage: cprint "text" [indent_level] [header_style]
# indent_level: 0=no indent, 1=2 spaces, 2=4 spaces, etc.
# header_style: none, bracket, dash, star, equal
cprint() {
    local text="$1"
    local indent="${2:-0}"
    local header="${3:-none}"
    local prefix=""
    
    # Create indentation (2 spaces per level)
    for ((i=0; i<indent; i++)); do
        prefix+="  "
    done
    
    # Apply header style
    case "$header" in
        "bracket")
            echo -e "\n${prefix}[${text}]"
            ;;
        "dash")
            echo -e "\n${prefix}- ${text}"
            ;;
        "star")
            echo -e "\n${prefix}* ${text}"
            ;;
        "equal")
            local line=$(printf '=%.0s' {1..50})
            echo -e "\n${line}"
            echo -e "${prefix}${text}"
            echo -e "${line}"
            ;;
        "double")
            local line=$(printf '=%.0s' {1..50})
            echo -e "\n${line}"
            echo -e "${prefix}${text}"
            echo -e "${line}"
            ;;
        *)
            echo -e "\n${prefix}${text}"
            ;;
    esac
}

# Print error message and exit
# Usage: cprint_error "error message" [exit_code]
cprint_error() {
    local text="$1"
    local exit_code="${2:-1}"
    cprint "ERROR: ${text}" 0 "bracket"
    exit $exit_code
}

# Print warning message
# Usage: cprint_warning "warning message"
cprint_warning() {
    local text="$1"
    cprint "WARNING: ${text}" 0 "bracket"
}

# Print success message
# Usage: cprint_success "success message"
cprint_success() {
    local text="$1"
    cprint "SUCCESS: ${text}" 0 "bracket"
}
