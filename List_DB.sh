#!/bin/bash
function list_databases() {
  
  source validation.sh
  local database_list=$(ls  Databases/| awk '{print $0 ".db"}')

  selected_db=$(zenity --list --width=300 --height=250 \
    --title="List of Databases" \
    --text="Choose a DB to connect to:" \
    --column="Databases" $database_list)

  if [ $? -eq 1 ]; then
    DBmenu
  fi

  if [ -z "$selected_db" ]; then
    DBmenu
  fi
  
  zenity --question --width=400 --height=100  --text="Do you want to connect to '$selected_db'?" 
  response=$?
  if [ $response -eq 0 ]; then
    connect_to_database "$selected_db"
  else
    zenity --info --width=400 --height=100 \
  --text="You chose not to connect to any database."
    DBmenu
  fi
}
list_databases
