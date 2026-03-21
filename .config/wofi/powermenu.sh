#!/usr/bin/env bash

chosen=$(printf "Lock\nLogout\nSuspend\nHibernate\nReboot\nShutdown" | wofi --dmenu --prompt "Power")

case "$chosen" in
  Lock) loginctl lock-session ;;
  Logout) hyprctl dispatch exit ;;
  Suspend) systemctl suspend ;;
  Hibernate) systemctl hibernate ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
