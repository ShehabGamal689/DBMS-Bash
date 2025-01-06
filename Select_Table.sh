#!/bin/bash

source ../../validation.sh

function Select_Tb() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  local Tables_list=$(ls "$current_dir/")
  local type=("All(*)" "Columns")
  local con=("Condition" "Conditionless")

  type=$(zenity --list \
      --title="How do you wish to select for the $DB_name.db" \
      --text="Choose a Method:" \
      --column="Tables" "${type[@]}")

  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  else
    if [ "$type" == "All(*)" ]; then
      Select_Without_Condition "$type"
    elif [ "$type" == "Columns" ]; then
      Select_Without_Condition "$type"
    fi
  fi
}
Select_Tb









