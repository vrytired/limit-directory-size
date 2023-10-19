#!/bin/bash

# Set the target directory and the maximum size in GiB
target_dir="/path/to/your/target/directory"
max_size_gib=30

# Check if the target directory exists
if [ ! -d "$target_dir" ]; then
  echo "Target directory not found: $target_dir"
  exit 1
fi

# Function to calculate the current directory size in GiB
get_dir_size_gib() {
  du -sb "$1" | awk '{ printf "%.2f", $1 / (1024^3) }'
}

# Function to delete the oldest file in the directory
delete_oldest_file() {
  local oldest_file
  oldest_file=$(find "$target_dir" -type f -print0 | xargs -0 ls -tr | head -n 1)
  if [ -n "$oldest_file" ]; then
    rm "$oldest_file"
    echo "Deleted: $oldest_file"
  fi
}

# Main loop to check and delete files
while true; do
  current_size_gib=$(get_dir_size_gib "$target_dir")

  if (( $(bc <<< "$current_size_gib > $max_size_gib") )); then
    delete_oldest_file
  else
    echo "Directory size is within the limit ($current_size_gib GiB <= $max_size_gib GiB)."
    break
  fi
done

echo "Script completed."
