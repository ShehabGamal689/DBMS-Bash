#!/bin/bash

function Delete_Data() {
  current_dir=$(pwd)
  DB_name=$(basename "$current_dir")
  Tables_list=$(ls "$current_dir/")

  if [ -z "$Tables_list" ]; then
      zenity --error --text="No tables found in the database."
      return
  fi

  selected_tb=$(zenity --list --width=300 --height=250 \
      --title="List of Tables in $DB_name.db" \
      --text="Choose a Table to delete from:" \
      --column="Tables" $Tables_list)

  if [ $? -ne 0 ] || [ -z "$selected_tb" ]; then
      zenity --info --text="Operation canceled."
      return
  fi

  table_name=$selected_tb
  data_file="../$DB_name/$table_name/$table_name"
  
  nf=$(awk -F':' 'NR>3 {print NR-3":"$1":"$3}' "$data_file.md")

  index=$(echo "$nf" | awk -F':' '$3 == "y" { print $1 }')
  
  col=$(echo "$nf" | awk -F':' '$3 == "y" { print $2 }')

  dv=$(zenity --entry --width=400 --title="Delete Record" \
      --text="Enter Value Of PK($col) for The Record You Want To Delete")

  if [ -z "$dv" ]; then
      zenity --info --text="Operation canceled."
      return
  fi

  DT=$(awk -F: -v selected_col="$col" '$1 == selected_col {print $2}' "$data_file.md")
  
  rtrn=$(data_type_match "$DT" "$dv")

  if [ "$rtrn" == "true" ]; then
      ltd=$(awk -v idx="$index" -v val="$dv" -F';' '$idx == val { print $0 }' "$data_file")
      
      if [ -z "$ltd" ]; then
          zenity --error --text="No record found for the given value."
          return
      fi

      zenity --question --text="Are you sure you want to delete this record?"
      
      if [ $? -eq 0 ]; then
          sed -i "\|$ltd|d" "$data_file"
          zenity --info --text="Record Deleted Successfully."
      else
          zenity --info --text="Operation canceled."
      
      fi
  else
      zenity --error --text="Data Type Mismatch. Expected: $DT"
  fi
}
Delete_Data
