#!/bin/bash

source validation.sh

function create_data_base {
while true; do
    db_name=$(zenity --entry --width=400 --height=100 \
      --title="Create Database" \
      --text="Enter database Name:")
    
    # if command didn't run successfully --> return to first menu
    if [ $? -eq 1 ]; then
      DBmenu
    fi
    
    db_namel=$(echo "$db_name" | awk '{print tolower($0)}') # make entered databse name lower case
    
    chk=$(check_for_empty_string $db_namel)
    if [ "$chk" == false ]; then
        chk=$(check_if_dir_exists $db_namel)
        if [ "$chk" == true ]; then 
            zenity --error --text="A database with the name $db_namel already exists."
        else
            chk=$(check_if_name_starts_with_number $db_namel)
            if [ "$chk" == true ]; then
                zenity --error --text="A database can't Start With Numbers."
            else
                chk=$(check_special_char $db_namel)
                if [ "$chk" == true ]; then
                    zenity --error --text="invalid name, avoid using special characters like: &, *, @"

                else
                    mkdir -p "Databases/$db_namel"
                    zenity --info --width=400 --height=100  --text="Database $db_namel.db created successfully!"
                    break  
                fi
            fi
        fi
    else
        zenity --error --width=400 --height=100  --text="Database Name can't be Empty"
    fi
done
}
create_data_base
