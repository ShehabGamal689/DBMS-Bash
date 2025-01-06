function Create_Table() {
  table_name=$(zenity --entry --width=400 --height=100 \
    --title="Create Table" \
    --text="Enter Table name:")

  if [ $? -eq 1 ] || [ -z "$table_name" ]; then
    zenity --error --text="Table creation canceled or invalid table name."
    return
  fi

  num_columns=$(zenity --entry --width=400 --height=100 \
    --title="Create Table $table_name" \
    --text="Enter number of columns:")

  if [ $? -eq 1 ] || ! [[ "$num_columns" =~ ^[0-9]+$ ]]; then
    zenity --error --text="Invalid number of columns. Table creation canceled."
    return
  fi

  mkdir "$table_name"
  touch "$table_name/$table_name" "$table_name/$table_name.md"
  echo "Table Name:$table_name" >"$table_name/$table_name.md"
  echo "Number of Columns:$num_columns" >>"$table_name/$table_name.md"
  echo -e "attribute_name:data_type:primary_key(y/n):unique(y/n):nullable(y/n)" >>"$table_name/$table_name.md"

  columns=()
  data_types=()
  primary_keys=()
  unique=()
  nullable=()

  for ((i = 1; i <= num_columns; i++)); do
    column_info=$(zenity --forms --width=300 --height=100 \
      --title="Create Table $table_name" \
      --text="Enter information for Column $i:" \
      --add-entry="Column Name" \
      --add-entry="Nullable (y/n)" \
      --add-entry="Unique (y/n)")

    if [ $? -eq 1 ]; then
      zenity --error --text="Table creation canceled."
      rm -r "$table_name"
      return
    fi

    column_name=$(echo "$column_info" | cut -d "|" -f 1)
    is_nullable=$(echo "$column_info" | cut -d "|" -f 2)
    is_unique=$(echo "$column_info" | cut -d "|" -f 3)

    # Validate column name
    if [ -z "$column_name" ]; then
      zenity --error --text="Column name cannot be empty. Table creation canceled."
      rm -r "$table_name"
      return
    fi

    # Validate Nullable field
    if [[ "$is_nullable" != "y" && "$is_nullable" != "n" ]]; then
      zenity --error --text="Invalid value for Nullable in Column $i. Must be 'y' or 'n'. Table creation canceled."
      rm -r "$table_name"
      return
    fi

    # Validate Unique field
    if [[ "$is_unique" != "y" && "$is_unique" != "n" ]]; then
      zenity --error --text="Invalid value for Unique in Column $i. Must be 'y' or 'n'. Table creation canceled."
      rm -r "$table_name"
      return
    fi

    # Select data type for the column
    data_type_options=("ID--Int--Auto--Inc." "Int" "Double" "Varchar" "Date")
    data_type=$(zenity --list --width=300 --height=350 \
      --title="Create Table $table_name" \
      --text="Select data type for Column $i:" \
      --column="Data Type" "${data_type_options[@]}")

    if [ $? -eq 1 ]; then
      zenity --error --text="Table creation canceled."
      rm -r "$table_name"
      return
    fi

    # Append validated values to arrays
    columns+=("$column_name")
    data_types+=("$data_type")
    nullable+=("$is_nullable")
    unique+=("$is_unique")
  done

  # Select Primary Key
  selected_pk_column=$(zenity --list --width=300 --height=250 \
    --title="Create Table $table_name" \
    --text="Select the Primary Key column:" \
    --column="Column" "${columns[@]}")

  if [ $? -eq 1 ] || [ -z "$selected_pk_column" ]; then
    zenity --error --text="No Primary Key column selected. Table creation canceled."
    rm -r "$table_name"
    return
  fi

  for column in "${columns[@]}"; do
    if [ "$column" == "$selected_pk_column" ]; then
      primary_keys+=("y")
    else
      primary_keys+=("n")
    fi
  done

  # Check for duplicate column names
  if [ "$(echo "${columns[@]}" | tr ' ' '\n' | sort | uniq -d | wc -l)" -ne 0 ]; then
    zenity --error --text="Duplicate column names found. Table creation canceled."
    rm -r "$table_name"
    return
  fi

  # Write columns to metadata file
  for ((i = 0; i < ${#columns[@]}; i++)); do
    echo -e "${columns[i]}:${data_types[i]}:${primary_keys[i]}:${unique[i]}:${nullable[i]}" >>"$table_name/$table_name.md"
  done

  zenity --info --text="Table '$table_name' created successfully!"
}
Create_Table
