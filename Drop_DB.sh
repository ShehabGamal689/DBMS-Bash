#!/bin/bash

function Drop_DB() {
  local database_list=$(ls Databases/)

  local database_list_with_extension=""
    for db in $database_list; do
        database_list_with_extension+="$db.db "
    done

  selected_db=$(zenity  --list --width=400 --height=300 \
    --title="List of Databases" \
    --text="Choose a database to Drop:" \
    --column="Databases" $database_list_with_extension)
  
  if [ $? -eq 1 ]; then
    DBmenu
    return
  fi

  zenity --question --width=400 --height=100  --text="Are you sure you want to delete the database '$selected_db'?\nAll tables and data inside this database will be permanently deleted."

  response=$?
  if [ $response -eq 0 ]; then
    local db=$(echo "$selected_db" | sed 's/\.db$//')
    rm -r "Databases/$db"
    zenity --info --width=400 --height=100 --text="Database '$selected_db' has been successfully deleted."
  else
    zenity --info --width=400 --height=100  --text="Deletion of database '$selected_db' has been canceled."
  fi
}

Drop_DB
