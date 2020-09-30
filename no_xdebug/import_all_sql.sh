!/bin/bash

for file in *.sql; do
    [ -f "$file" ] || continue
    printf "$file\n"
    wp db query --allow-root < $file
done