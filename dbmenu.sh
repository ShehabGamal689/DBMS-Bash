#!/bin/bash


function DBmenu(){
    while true; do
    choice=$(zenity --list --title="DBMS Main Menu" --text="Choose an option:" \
            --column="Option" --column="Description" \
            1 "Create Database" \
            2 "List Databases" \
            3 "Connect to Database" \
            4 "Drop Database" \
            5 "Exit" \
            --height=300 --width=400)
    if [ $? -eq 1 ];then
        echo "Goodbye XD !"
        exit 
    else
        case $choice in
            1 )
                source Create_DB.sh;;
            2 )
                source List_DB.sh;;
            3 )
                source Connect_DB.sh;;
            4 )
                source Drop_DB.sh;;
            5 )
                exit 0;;
            *)
                zenity --error --text="Invalid choice. Please try again." ;;
        esac
    fi
    
done
}

DBmenu
