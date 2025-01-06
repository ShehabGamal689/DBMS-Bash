#!/bin/bash

# Base Directory for Databases
BASE_DIR=$(pwd)

# Main Menu Function
function main_menu() {
    while true; do
        echo "Main Menu:"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"
        read -p "Choose an option: " choice

        case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Create Database Function
function create_database() {
    read -p "Enter database name: " db_name
    if [ -d "$BASE_DIR/$db_name" ]; then
        echo "Database already exists."
    else
        mkdir "$BASE_DIR/$db_name"
        echo "Database '$db_name' created successfully."
    fi
}

# List Databases Function
function list_databases() {
    echo "Available Databases:"
    ls -d */ | sed 's#/##'
}

# Connect To Database Function
function connect_database() {
    read -p "Enter database name to connect: " db_name
    if [ -d "$BASE_DIR/$db_name" ]; then
        echo "Connected to database '$db_name'."
        cd "$BASE_DIR/$db_name" || exit
        database_menu
        cd "$BASE_DIR" || exit
    else
        echo "Database does not exist."
    fi
}

# Drop Database Function
function drop_database() {
    read -p "Enter database name to drop: " db_name
    if [ -d "$BASE_DIR/$db_name" ]; then
        read -p "Are you sure you want to delete '$db_name'? (y/n): " confirm
        if [ "$confirm" == "y" ]; then
            rm -rf "$BASE_DIR/$db_name"
            echo "Database '$db_name' deleted successfully."
        else
            echo "Operation canceled."
        fi
    else
        echo "Database does not exist."
    fi
}

# Database Menu Function
function database_menu() {
    while true; do
        echo "Database Menu:"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert Into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Row"
        echo "8. Back to Main Menu"
        read -p "Choose an option: " choice

        case $choice in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_row ;;
            8) break ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Create Table Function
function create_table() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name.meta" ]; then
        echo "Table already exists."
    else
        read -p "Enter number of columns: " num_columns
        columns=()
        types=()

        for ((i=1; i<=num_columns; i++)); do
            read -p "Enter name of column $i: " col_name
            read -p "Enter type of column $i (string/int): " col_type
            columns+=("$col_name")
            types+=("$col_type")
        done

        echo "Table Name: $table_name" > "$table_name.meta"
        echo "Number of Columns: $num_columns" >> "$table_name.meta"
        echo "Columns: ${columns[*]}" >> "$table_name.meta"
        echo "Types: ${types[*]}" >> "$table_name.meta"
        touch "$table_name.data"
        echo "Table '$table_name' created successfully."
    fi
}

# List Tables Function
function list_tables() {
    echo "Available Tables:"
    ls *.meta 2>/dev/null | sed 's/.meta$//'
}

# Drop Table Function
function drop_table() {
    read -p "Enter table name to drop: " table_name
    if [ -f "$table_name.meta" ]; then
        rm "$table_name.meta" "$table_name.data"
        echo "Table '$table_name' deleted successfully."
    else
        echo "Table does not exist."
    fi
}

# Insert Into Table Function
function insert_into_table() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name.meta" ]; then
        columns=($(grep "Columns:" "$table_name.meta" | cut -d: -f2 | tr -d ','))
        types=($(grep "Types:" "$table_name.meta" | cut -d: -f2 | tr -d ','))

        row=()
        for ((i=0; i<${#columns[@]}; i++)); do
            read -p "Enter value for ${columns[i]} (${types[i]}): " value

            if [ "${types[i]}" == "int" ] && ! [[ "$value" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. ${columns[i]} must be an integer."
                return
            fi

            row+=("$value")
        done
        echo "${row[*]}" >> "$table_name.data"
        echo "Row inserted successfully."
    else
        echo "Table does not exist."
    fi
}

# Select From Table Function
function select_from_table() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name.meta" ]; then
        echo "Table Data:"
        cat "$table_name.data"
    else
        echo "Table does not exist."
    fi
}

# Delete From Table Function
function delete_from_table() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name.meta" ]; then
        read -p "Enter primary key value to delete: " pk
        sed -i "/^$pk /d" "$table_name.data"
        echo "Row deleted successfully."
    else
        echo "Table does not exist."
    fi
}

# Update Row Function
function update_row() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name.meta" ]; then
        read -p "Enter primary key value to update: " pk
        old_row=$(grep "^$pk " "$table_name.data")

        if [ -z "$old_row" ]; then
            echo "Row with primary key '$pk' not found."
            return
        fi

        columns=($(grep "Columns:" "$table_name.meta" | cut -d: -f2 | tr -d ','))
        new_row=()

        for col in "${columns[@]}"; do
            read -p "Enter new value for $col (leave blank to keep current value): " value
            if [ -z "$value" ]; then
                new_row+=($(echo "$old_row" | cut -d' ' -f$((i+1))))
            else
                new_row+=("$value")
            fi
        done

        sed -i "/^$pk /c\${new_row[*]}" "$table_name.data"
        echo "Row updated successfully."
    else
        echo "Table does not exist."
    fi
}

# Start the Application
main_menu

