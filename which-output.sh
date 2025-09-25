# ~/.config/waybar/bin/which-output.sh
#!/usr/bin/env bash
hyprctl -j monitors | jq -r '.[] | select(.focused==true).name'
