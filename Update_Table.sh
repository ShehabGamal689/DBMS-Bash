function Update_Table() {
  tables=($(ls -d */ | sed 's#/##')) # List all directories (tables)
  if [ ${#tables[@]} -eq 0 ]; then
    zenity --error --width=400 --height=100 --text="No tables found to update."
    return
  fi

  table_name=$(zenity --list --width=300 --height=250 \
    --title="Select Table to Update" \
    --text="Choose a table to update:" \
    --column="Tables" "${tables[@]}")

  if [ $? -eq 1 ] || [ -z "$table_name" ]; then
    zenity --error --text="Table update operation canceled."
    return
  fi

  update_option=$(zenity --list --width=300 --height=300 \
    --title="Update Table $table_name" \
    --text="What would you like to do?" \
    --column="Options" \
    "Update Column Value" \
    "Modify Column Attributes" \
    "Add New Column" \
    "Remove Existing Column" \
    "Exit")

  case $update_option in
    "Modify Column Attributes")
      Modify_Column_Attributes "$table_name"
      ;;
    "Add New Column")
      Add_New_Column "$table_name"
      ;;
    "Remove Existing Column")
      Remove_Existing_Column "$table_name"
      ;;
    "Update Column Value")
      Update_Column_Value "$table_name"
      ;;
    "Exit")
      return
      ;;
    *)
      zenity --error --width=400 --height=100 --text="Invalid option. Please try again."
      Update_Table
      ;;
  esac
}

function Update_Column_Value() {
  table_name=$1
  column_md_file="$table_name/$table_name.md"
  data_file="$table_name/$table_name"

  if [ ! -s "$data_file" ]; then
    zenity --error --width=400 --height=100 --text="No data found in table '$table_name'."
    return
  fi

  # Get column names from the metadata file
  columns=($(awk -F':' 'NR>3 {print $1}' "$column_md_file"))
  selected_column=$(zenity --list --width=300 --height=250 \
    --title="Update Column Value" \
    --text="Select a column to update its value:" \
    --column="Column" "${columns[@]}")

  if [ $? -eq 1 ] || [ -z "$selected_column" ]; then
    zenity --error --text="Column selection canceled."
    return
  fi

  # Identify the primary key from the metadata file
  primary_key=$(awk -F':' 'NR>3 && $3=="y" {print $1}' "$column_md_file")
  pk_value=$(zenity --entry --width=300 --height=100 \
    --title="Update Column Value" \
    --text="Enter the value of Primary Key ($primary_key) for the row to update:")

  if [ $? -eq 1 ] || [ -z "$pk_value" ]; then
    zenity --error --text="Primary key value is required."
    return
  fi

  # Verify the primary key exists in the data file
  if ! grep -q "^$pk_value;" "$data_file"; then
    zenity --error --width=400 --height=100 --text="No record found with Primary Key '$pk_value'."
    return
  fi

  # Get new value for the selected column
  new_value=$(zenity --entry --width=300 --height=100 \
    --title="Update Column Value" \
    --text="Enter the new value for column '$selected_column':")

  if [ $? -eq 1 ]; then
    zenity --error --text="Value update operation canceled."
    return
  fi

  # Determine the column index for the selected column using metadata
  column_index=$(awk -F':' -v col="$selected_column" 'NR>3 {if ($1 == col) print NR - 3}' "$column_md_file")

  if [ -z "$column_index" ]; then
    zenity --error --text="Column '$selected_column' not found in metadata."
    return
  fi

  # Update the specific column in the data file
  awk -F';' -v pk="$pk_value" -v col_idx="$column_index" -v new_val="$new_value" -v OFS=';' '
    $1 == pk { $col_idx = new_val }
    { print }
  ' "$data_file" > "$data_file.tmp" && mv "$data_file.tmp" "$data_file"

  zenity --info --width=400 --height=100 --text="Value updated successfully for column '$selected_column'."
}



function Modify_Column_Attributes() {
  table_name=$1
  column_md_file="$table_name/$table_name.md"

  columns=($(awk -F':' 'NR>3 {print $1}' "$column_md_file"))
  selected_column=$(zenity --list --width=300 --height=250 \
    --title="Modify Column Attributes" \
    --text="Select a column to modify:" \
    --column="Column" "${columns[@]}")

  if [ $? -eq 1 ]; then
    zenity --error --text="Modification canceled."
    Update_Table
    return
  fi

  column_line=$(grep -n "^$selected_column:" "$column_md_file" | cut -d: -f1)

  if [[ -z $column_line ]]; then
    zenity --error --width=400 --height=100 --text="Column '$selected_column' not found."
    Modify_Column_Attributes "$table_name"
    return
  fi

  new_nullable=$(zenity --entry --width=300 --height=100 \
    --title="Modify Column Attributes" \
    --text="Enter new nullable value for '$selected_column' (y/n):")
  new_unique=$(zenity --entry --width=300 --height=100 \
    --title="Modify Column Attributes" \
    --text="Enter new unique value for '$selected_column' (y/n):")

  if [[ "$new_nullable" != "y" && "$new_nullable" != "n" ]] || [[ "$new_unique" != "y" && "$new_unique" != "n" ]]; then
    zenity --error --width=400 --height=100 --text="Invalid nullable or unique value."
    Modify_Column_Attributes "$table_name"
    return
  fi

  sed -i "${column_line}s/\([^:]*:[^:]*:[^:]*:\)[^:]*:\([^:]*\)/\1$new_unique:$new_nullable/" "$column_md_file"

  zenity --info --width=400 --height=100 --text="Column '$selected_column' updated successfully."
}


function Add_New_Column() {
  table_name=$1
  column_md_file="$table_name/$table_name.md"

  column_info=$(zenity --forms --width=300 --height=150 \
    --title="Add New Column" \
    --text="Enter information for the new column:" \
    --add-entry="Column Name" \
    --add-entry="Nullable (y/n)" \
    --add-entry="Unique (y/n)")

  if [ $? -eq 1 ]; then
    zenity --error --text="Adding new column canceled."
    Update_Table
    return
  fi

  column_name=$(echo "$column_info" | cut -d "|" -f 1)
  is_nullable=$(echo "$column_info" | cut -d "|" -f 2)
  is_unique=$(echo "$column_info" | cut -d "|" -f 3)

  data_type_options=("Int" "Double" "Varchar" "Date")
  data_type=$(zenity --list --width=300 --height=250 \
    --title="Add New Column" \
    --text="Select data type for the new column:" \
    --column="Data Type" "${data_type_options[@]}")

  if [[ "$is_nullable" != "y" && "$is_nullable" != "n" ]] || [[ "$is_unique" != "y" && "$is_unique" != "n" ]]; then
    zenity --error --width=400 --height=100 --text="Invalid nullable or unique value."
    Add_New_Column "$table_name"
    return
  fi

  echo "$column_name:$data_type:n:$is_unique:$is_nullable" >> "$column_md_file"

  zenity --info --width=400 --height=100 --text="Column '$column_name' added successfully."
}

function Remove_Existing_Column() {
  table_name=$1
  column_md_file="$table_name/$table_name.md"

  columns=($(awk -F':' 'NR>3 {print $1}' "$column_md_file"))
  selected_column=$(zenity --list --width=300 --height=250 \
    --title="Remove Existing Column" \
    --text="Select a column to remove:" \
    --column="Column" "${columns[@]}")

  if [ $? -eq 1 ]; then
    zenity --error --text="Removing column canceled."
    Update_Table
    return
  fi

  sed -i "/^$selected_column:/d" "$column_md_file"

  zenity --info --width=400 --height=100 --text="Column '$selected_column' removed successfully."
}



Update_Table

