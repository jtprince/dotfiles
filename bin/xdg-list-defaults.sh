#!/bin/bash

find /usr/share/applications ~/.local/share/applications -iname '*.desktop' -print0 | while IFS= read -r -d $'\0' d; do
  for m in $(grep MimeType "$d" | cut -d= -f2 | tr ";" " "); do
    echo "'$d'" "'$m'"
  done
done

echo ""
echo "To alter:"
echo "xdg-mime default <desktop-file> <mime-type> ..."
