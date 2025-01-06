#!/bin/bash

# Base Directory for Databases
BASE_DIR=$(pwd)

# Main Menu Function
function main_menu() {
    while true; do
        choice=$(zenity --list --title="DBMS Main Menu" --text="Choose an option:" \
            --column="Option" --column="Description" \
            1 "Create Database" \
            2 "List Databases" \
            3 "Connect to Database" \
            4 "Drop Database" \
            5 "Exit" \
            --height=300 --width=400)
        
        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) exit 0 ;;
            *) zenity --error --text="Invalid option. Please try again." ;;
        esac
    done
}

# Create Database Function
function create_database() {
    db_name=$(zenity --entry --title="Create Database" --text="Enter database name:")
    if [ -z "$db_name" ]; then
        zenity --error --text="Database name cannot be empty."
    elif [ -d "$BASE_DIR/$db_name" ]; then
        zenity --error --text="Database already exists."
    else
        mkdir "$BASE_DIR/$db_name"
        zenity --info --text="Database '$db_name' created successfully."
    fi
}

# List Databases Function
function list_databases() {
    databases=$(ls -d */ 2>/dev/null | sed 's#/##')
    if [ -z "$databases" ]; then
        zenity --info --text="No databases found."
    else
        zenity --list --title="Available Databases" --text="Select a database:" \
            --column="Databases" $databases --height=300 --width=400
    fi
}

# Connect To Database Function
function connect_database() {
    db_name=$(zenity --entry --title="Connect to Database" --text="Enter database name to connect:")
    if [ -d "$BASE_DIR/$db_name" ]; then
        zenity --info --text="Connected to database '$db_name'."
        cd "$BASE_DIR/$db_name" || exit
        database_menu
        cd "$BASE_DIR" || exit
    else
        zenity --error --text="Database does not exist."
    fi
}

# Drop Database Function
function drop_database() {
    db_name=$(zenity --entry --title="Drop Database" --text="Enter database name to drop:")
    if [ -d "$BASE_DIR/$db_name" ]; then
        confirm=$(zenity --question --title="Confirm Delete" --text="Are you sure you want to delete '$db_name'?")
        if [ $? -eq 0 ]; then
            rm -rf "$BASE_DIR/$db_name"
            zenity --info --text="Database '$db_name' deleted successfully."
        fi
    else
        zenity --error --text="Database does not exist."
    fi
}

# Database Menu Function
function database_menu() {
    while true; do
        choice=$(zenity --list --title="Database Menu" --text="Choose an option:" \
            --column="Option" --column="Description" \
            1 "Create Table" \
            2 "List Tables" \
            3 "Drop Table" \
            4 "Insert Into Table" \
            5 "Select From Table" \
            6 "Delete From Table" \
            7 "Update Row" \
            8 "Back to Main Menu" \
            --height=400 --width=500)
        
        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_row ;;
            8) break ;;
            *) zenity --error --text="Invalid option. Please try again." ;;
        esac
    done
}

# Create Table Function
function create_table() {
    table_name=$(zenity --entry --title="Create Table" --text="Enter table name:")
    if [ -z "$table_name" ]; then
        zenity --error --text="Table name cannot be empty."
    elif [ -f "$table_name.meta" ]; then
        zenity --error --text="Table already exists."
    else
        num_columns=$(zenity --entry --title="Create Table" --text="Enter number of columns:")
        if ! [[ "$num_columns" =~ ^[0-9]+$ ]]; then
            zenity --error --text="Invalid number of columns."
            return
        fi

        columns=()
        types=()

        for ((i=1; i<=num_columns; i++)); do
            col_name=$(zenity --entry --title="Column Name" --text="Enter name for column $i:")
            col_type=$(zenity --list --title="Column Type" --text="Select type for column $i:" \
                --column="Type" string int --height=200 --width=300)
            
            if [ -z "$col_name" ] || [ -z "$col_type" ]; then
                zenity --error --text="Column name and type are required."
                return
            fi

            columns+=("$col_name")
            types+=("$col_type")
        done

        # Save table metadata and create data file
        echo "Table Name: $table_name" > "$table_name.meta"
        echo "Number of Columns: $num_columns" >> "$table_name.meta"
        echo "Columns: ${columns[*]}" >> "$table_name.meta"
        echo "Types: ${types[*]}" >> "$table_name.meta"
        touch "$table_name.data"

        zenity --info --text="Table '$table_name' created successfully."
    fi
}

# List Tables Function
function list_tables() {
    tables=$(ls *.meta 2>/dev/null | sed 's/.meta$//')
    if [ -z "$tables" ]; then
        zenity --info --text="No tables found."
    else
        zenity --list --title="Available Tables" --text="Select a table:" \
            --column="Tables" $tables --height=300 --width=400
    fi
}

# Drop Table Function
function drop_table() {
    table_name=$(zenity --entry --title="Drop Table" --text="Enter table name to drop:")
    if [ -f "$table_name.meta" ]; then
        zenity --question --title="Confirm Delete" --text="Are you sure you want to delete table '$table_name'?"
        if [ $? -eq 0 ]; then
            rm "$table_name.meta" "$table_name.data"
            zenity --info --text="Table '$table_name' deleted successfully."
        fi
    else
        zenity --error --text="Table does not exist."
    fi
}

# Insert Into Table Function
function insert_into_table() {
    table_name=$(zenity --entry --title="Insert Into Table" --text="Enter table name:")
    if [ -f "$table_name.meta" ]; then
        columns=($(grep "Columns:" "$table_name.meta" | cut -d: -f2 | tr -d ','))
        types=($(grep "Types:" "$table_name.meta" | cut -d: -f2 | tr -d ','))

        row=()
        for ((i=0; i<${#columns[@]}; i++)); do
            value=$(zenity --entry --title="Insert Value" --text="Enter value for ${columns[i]} (${types[i]}):")
            
            if [ "${types[i]}" == "int" ] && ! [[ "$value" =~ ^[0-9]+$ ]]; then
                zenity --error --text="Invalid input. ${columns[i]} must be an integer."
                return
            fi
            
            row+=("$value")
        done

        echo "${row[*]}" >> "$table_name.data"
        zenity --info --text="Row inserted successfully."
    else
        zenity --error --text="Table does not exist."
    fi
}

# Select From Table Function
function select_from_table() {
    table_name=$(zenity --entry --title="Select From Table" --text="Enter table name:")
    if [ -f "$table_name.meta" ]; then
        data=$(cat "$table_name.data")
        if [ -z "$data" ]; then
            zenity --info --text="Table '$table_name' is empty."
        else
            zenity --text-info --title="Table Data" --filename="$table_name.data" --height=400 --width=600
        fi
    else
        zenity --error --text="Table does not exist."
    fi
}

# Delete From Table Function
function delete_from_table() {
    table_name=$(zenity --entry --title="Delete From Table" --text="Enter table name:")
    if [ -f "$table_name.meta" ]; then
        pk=$(zenity --entry --title="Delete Row" --text="Enter primary key value to delete:")
        if grep -q "^$pk " "$table_name.data"; then
            sed -i "/^$pk /d" "$table_name.data"
            zenity --info --text="Row deleted successfully."
        else
            zenity --error --text="Row with primary key '$pk' not found."
        fi
    else
        zenity --error --text="Table does not exist."
    fi
}

# Update Row Function
function update_row() {
    table_name=$(zenity --entry --title="Update Row" --text="Enter table name:")
    if [ -f "$table_name.meta" ]; then
        pk=$(zenity --entry --title="Update Row" --text="Enter primary key value to update:")
        old_row=$(grep "^$pk " "$table_name.data")

        if [ -z "$old_row" ]; then
            zenity --error --text="Row with primary key '$pk' not found."
            return
        fi

        columns=($(grep "Columns:" "$table_name.meta" | cut -d: -f2 | tr -d ','))
        new_row=()

        for col in "${columns[@]}"; do
            value=$(zenity --entry --title="Update Value" --text="Enter new value for $col (leave blank to keep current):")
            if [ -z "$value" ]; then
                new_row+=($(echo "$old_row" | cut -d' ' -f$((i+1))))
            else
                new_row+=("$value")
            fi
        done

        sed -i "/^$pk /c\${new_row[*]}" "$table_name.data"
        zenity --info --text="Row updated successfully."
    else
        zenity --error --text="Table does not exist."
    fi
}

main_menu

