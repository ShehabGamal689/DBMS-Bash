#!/bin/bash
function list_tables() {
  current_dir=$(pwd)

  DB_name=$(basename "$current_dir")

  local Tables_list=$(ls "$current_dir/")

  selected_tb=$(zenity --list --width=300 --height=250 \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    echo $(current_dir)
    Menu_Table $DB_name
  fi

}
list_tables
