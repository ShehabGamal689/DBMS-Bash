#!/bin/bash

function Menu_Table() {
    while
        selected_table=$(zenity --list --title="Database Menu" --text="Choose an operation for the Database '$1':" \
            --column="Option" --column="Description" \
            1 "Create Table" \
            2 "List Tables" \
            3 "Drop Table" \
            4 "Insert Into Table" \
            5 "Select From Table" \
            6 "Delete From Table" \
            7 "Update Table" \
            8 "Disconnect From Database" \
            --height=400 --width=500)
            
        if [ $? -eq 1 ]; then
            cd ../..
            echo "Current directory: $(pwd)"
            DBmenu
        else
            case "$selected_table" in
                1 )
                    source ../../Create_Table.sh $1;;
                2 )
                    source ../../List_Tables.sh;;
                3 )
                    source ../../Drop_Table.sh;;
                4 )
                    source ../../Insert_Table.sh;;
                5 )
                    source ../../Select_Table.sh;;
                6 )
                    source ../../Delete_Table.sh;;
                7 )
                    source ../../Update_Table.sh;;
                8 )
                    return
                    ;;
                *)
                if [ $? -eq 1 ]; then
                    cd ../..
                    echo "Current directory: $(pwd)"
                    DBmenu
                else
                    zenity --error --width=400 --height=100 --text="Invalid choice. Please try again."
                fi
                ;;
            esac
        fi
    do :; done
}

Menu_Table $1


