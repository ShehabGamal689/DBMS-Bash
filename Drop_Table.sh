 #!/bin/bash

function Drop_tb() {
 current_dir=$(pwd)

 DB_name=$(basename "$current_dir")

 local Tables_list=$(ls "$current_dir/")

  selected_tb=$(zenity --list  --width=300 --height=250 \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table To Drop:" \
    --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table $DB_name
    return
  fi

  zenity --question --width=400 --height=100  --text="Are you sure you want to delete the Table '$DB_name.$selected_tb'?\nAll data inside this table will be permanently deleted."

  response=$?
  if [ $response -eq 0 ]; then
    rm -r "../$DB_name/$selected_tb/"
    zenity --info --width=400 --height=100  --text="Database '$DB_name.$selected_tb' has been successfully deleted."
  else
    zenity --info --width=400 --height=100  --text="Deletion of database '$DB_name.$selected_tb' has been canceled."
  fi
}

Drop_tb
