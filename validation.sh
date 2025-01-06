#!/bin/bash

#BASE_DIR="/home/shehab-gamal/dbms-bash/databases"
BASE_DIR=$(pwd) 


# list databases and choose one to connect to 
function connect_to_database() {
  db_name=$(echo "$1" | sed 's/\.db$//')

  cd "Databases/$db_name"
  zenity --info --width=400 --height=100 \
  --text="Connected to the database: $db_name"
  echo "Current directory: $(pwd)"
  source ../../tablemenu.sh $db_name
}

# list databases and choose one to connect to
function list_databases() {
  source validation.sh
  local database_list=$(ls  Databases/| awk '{print $0 ".db"}')

  selected_db=$(zenity --list --width=300 --height=250 \
    --title="List of Databases" \
    --text="Choose a DB to connect to:" \
    --column="Databases" $database_list)

  if [ $? -eq 1 ]; then
    DBmenu
  fi

  if [ -z "$selected_db" ]; then
    DBmenu
  fi
  
  zenity --question --width=400 --height=100  --text="Do you want to connect to '$selected_db'?" 
  response=$?
  if [ $response -eq 0 ]; then
    connect_to_database "$selected_db"
  else
    zenity --info --width=400 --height=100 \
  --text="You chose not to connect to any database."
    DBmenu
  fi
}

# takes a string argument and check f it's empty or not
function check_for_empty_string {
  if [ -z $1 ]
  then
    echo true
  else
    echo false
  fi
}

# takes a directory argument and check if it exists
function check_if_dir_exists {
	if [[ -d "$*" ]]
	then
		echo true
	else
		echo false
	fi
}

# takes two argument (first[column name] , second[table name]) and check if column already exists
function check_for_repeated_col_name {
  col_name=$1
  table_name=$2 
  count=$(cut -d ':' -f1 "$table_name" | grep -i "^$col_name$" | wc -l)
  echo $count  
}

# takes a string arument to check if it contains any special characters
function check_special_char {
  x=$*
  if [[ $x =~ [\!\'\"\^\\[\#\`\~\$\%\=\+\<\>\|\:\ \(\)\@\;\?\&\*\\\/]+ ]]
  then
    echo true
  else
    echo false
  fi
}

# takes a string arument to check if it starts with a number
function check_if_name_starts_with_number {
  if [[ $1 =~ ^[0-9] ]]
  then
    echo true
  else
    echo false
  fi
}

# takes an arument, converts it to lower case to check if it contains any special characters
function check_data_type_entry {
    dt_lower=$(echo "$1" | awk '{print tolower($0)}')
    case $dt_lower in
    number)
    ;;
    double)
    ;;
    string)
    ;;
    auto_increment)
    ;;
    "date")
    ;;
    date_time)
    ;;
    email)
    ;;
    text)
    ;;
    *)
    echo "invalid data type"
    ;;
    esac
}

# check if an argument is valid (empty_name , special_characters , starts_with_number)
function arguments_checker {
  arguments=`echo $* | cut -d ' ' -f 3-`
  arg_name=$1
  
  rtrn=$(check_special_char $1)
  if [ $rtrn == true ]
  then
      echo "name can't contain a special characters"
      return 1
  else
      rtrn=$(check_if_name_starts_with_number $1)
      if [ $rtrn == true ]
      then
          echo "name can't start with numbers"
          return 1
      else
          rtrn=$(check_for_empty_string $1)
          if [ $rtrn == true ]
          then
              echo "column name must be provided"
              return 1
          fi
      fi
  fi
  dt=$2
  # check if data type is valid using case state
  rtrn=$(check_data_type_entry $dt)
  if [ rtrn == "invalid data type" ]
  then
      echo "invalid data type"
      return 1
  fi
  pk=`echo $arguments | grep -i primary_key| wc -l`
  nn=`echo $arguments | grep -i not_null| wc -l`
  uq=`echo $arguments | grep -i unique | wc -l`
  inc=`echo $arguments | grep -i auto_increment |wc -l`
  line_to_be_added="$1:$2"
  for constraint in $pk $inc $uq $nn
  do
          if [ $constraint -eq 1 ]
          then
                  line_to_be_added="$line_to_be_added:y"
          elif [ $constraint -eq 0 ]
          then
                  line_to_be_added="$line_to_be_added:n"
          else
                  echo "too many arguments after $1"
          fi
  done
  echo $line_to_be_added
}

# check if an argument (table name) is valid (empty_name , special_characters , starts_with_number) plus check if a table with same name already exists
function Tb_txf {

  arg_name=$(echo $* | awk '{print tolower($0)}')

  # Check for naming constraints
  rtrn=$(check_special_char $arg_name)
  if [ "$rtrn" == true ]; then
     zenity --error --width=400 --height=100  --text="Name can't contain special characters"
    return 1
  else
    rtrn=$(check_if_name_starts_with_number $arg_name)
    if [ "$rtrn" == true ]; then
       zenity --error --width=400 --height=100  --text="Name can't start with numbers"
      return 1
    else
      rtrn=$(check_for_empty_string $arg_name)
      if [ "$rtrn" == true ]; then
         zenity --error --width=400 --height=100  --text="Column name must be provided"
        return 1
      else
        rtrn=$(check_if_dir_exists $arg_name)
        if [ "$rtrn" == true ]; then
          echo  zenity --error --width=400 --height=100  --text="Table name already exists in your DB"
          return 1
        else
          echo true  # All checks passed successfully
        fi
      fi
    fi
  fi
}


function append_attribute {
  filtered_line=`echo $* | cut -d \( -f 2 |cut -d \) -f 1`
  echo $filtered_line | sed 's/,/\n/g' > temp.md
  table_name=`echo $* | cut -d " " -f 3`
  rm $table_name.md
  while read line; do arguments_checker $line >> $table_name.md; done < temp.md
  rm temp.md
}

# function to define format for each data type
function data_type {

  shopt -s extglob

  input=$*
  
  int="^[1-9][0-9]*$"
  double="^[-+]?[0-9]+\.?[0-9]*$"
  str="^[a-zA-Z0-9 ]{0,255}$"
  date_pattern="^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$"
  date_time_pattern="^[0-9]{4}-((0[1-9])|(1[0-2]))-((0[1-9])|([1-2][0-9])(3[0-1]))---((2[0-3])|([0-1][0-9])):[0-5][0-9]:[0-5][0-9]$"
  email_pattern="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$"
  enum_pattern="^(([0-9]+)|([a-zA-Z0-9 ]+))(,(([0-9]+)|([a-zA-Z0-9 ]+)))*$"
  phone_pattern="^01[0-9]{9}$"
 
  if  [[ $input =~ $int ]]
  then
    echo "int"
  elif [[ $input =~ $double ]]
  then
    echo "double"
  elif [[ $input =~ $str ]]
  then
    echo "varchar"
  elif [[ $input =~ $date_pattern ]]
  then
    echo "date"
  else
    echo "text"
  fi
}

#validate if a given value is a number
function isNumber {
  if [[ $* =~ ^[1-9][0-9]*$ ]]; then
    echo "true"
  else
    echo "false"
  fi
}

#
function check_repeated_columns {
  local columns=("$@")

  declare -A column_counts

  for column in "${columns[@]}"; do
    ((column_counts["$column"]++))
  done

  for column in "${!column_counts[@]}"; do
    if [ "${column_counts[$column]}" -gt 1 ]; then
      echo "You Can't Have 2 Columns with the Same Name"
      return 1
    fi
  done

  return 0
}




#function to check if a value matches its data type (it takes expected datatype first then the input)
function data_type_match {
    
  expected_data_type=$1
  if [ "$expected_data_type" == "ID--Int--Auto--Inc." ]; 
  then
  expected_data_type="INT"
  fi
  lower_expected=`echo $expected_data_type | awk '{print tolower($0)}'`
  shift
  if [ "$lower_expected" == "password" ]; then
    vp=$(validate_password_strength "$1")
    if [ "$vp" == true ]; then
        echo true
    else
        echo false
    fi
  else
    data_type=$(data_type "$*")
    # echo $data_type
    if [ "$lower_expected" == "$data_type" ]; then
        echo true
    else
        echo false
    fi
  fi

}

# data_type_match "Phone" "01011339798"

#function to check if a value already exists in data file to ensure uniqness constraint
function check_for_unique {
   
    col=$1
    file=$2
    shift 2
    data=$*
    count=$(cat $file | cut -d ';' -f $col | grep -i ^"$data"$ | wc -l)
    if [ $count -eq 0 ]
    then
        echo true
    else
        echo false
    fi
}

#check_for_unique 1 ./Databases/shehab/Employee/Employee 5

#function to check if a value isn't null in data file to ensure nullable constraint
function check_for_not_null {
    input=$*
    if [ -z "$input" ]
    then
        echo false    #empty string = null
    else
        echo true
    fi
}

#function to validate Pk USING uniqness and not nullable constraints
function check_for_pk {
    col=$1
    file=$2
    shift 2
    data=$*
    rtrn=$(check_for_not_null $data)
    if [ $rtrn == true ]
    then
        rtrn=$(check_for_unique "$col" "$file" "$data")
        if [ "$rtrn" == true ]
        then
            	echo true
	else
		echo false
        fi
    else
        echo false
    fi
}

function check_for_data_type {
    col=$1
    file=$2
    shift 2
    data=$*
    expected_data_type=`awk -v mycol=$col -F ":" '{ if (NR==mycol)
    {print $2}
 }
    ' $file`
    rtrn=$(data_type_match $expected_data_type $data)
    echo $rtrn
}
#check_for_data_type 8 ./Student/Student.md "2024-12-32 23:59:59"
#check_for_not_null                 
#check_for_unique 1 /etc/passwd Caster
#check_for_pk 1 /etc/passwd asdasq asfsaga asd


#function to check if a column already exists in meta data file (TAKES file of metadata as an argument)
function check_if_col_exists {
    meta_data_file=$1
    col_name=$2
    col_num=`cat $meta_data_file|cut -d : -f 1 |grep -n ^$col_name$` #returns number:name
    if [ -z $col_num ]
    then
        echo "false"
    else
    num=`echo $col_num| cut -d : -f 1`
    num=$((num-3))
    echo $num
    fi
}

#function to select all coulmn names and their values from a given table
function Select_All() {

  current_dir=$(pwd) #get current directory
  DB_name=$(basename "$current_dir") #get last entry from current directory (database name)

  local Tables_list=$(ls "$current_dir/") #list all tables in that directory
  
  selected_tb=$(zenity --list --width=300 --height=250  \
    --title="List of Tables in $DB_name.db" \
    --text="Choose a Table:" \
    --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi

  table_name="$selected_tb"
  data_file="../$DB_name/$table_name/$table_name"

  headers=$(awk -F: 'NR>3 {print $1}' "$data_file.md") # get all column names and store then in headers array
  num_fields=$(awk -F: 'NR>3 {print NR-3}' "$data_file.md" | wc -l) # get number of fields in data file
  pk=$(awk -F':' '$3 == "y" { print $1 }' "$data_file.md") # get pk from meta data file (where after line 3, thrid argumen == y)

  # Creating a basic HTML structure with tables
  formatted_data="<html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
        }
        table {
          border-collapse: collapse;
          width: 100%;
        }
        th, td {
          border: 1px solid #dddddd;
          text-align: left;
          padding: 8px;
        }
        th {
          background-color: #f2f2f2;
        }
      </style>
    </head>
    <body>
      <h2>$table_name Table</h2>
      <h5 style='color:crimson'><b>$pk</b> is the <b>PK</b> for this Table</h5>
      <table>
        <tr>"

  for header in $headers; do
    formatted_data+="<th>$header</th>"
  done

  #formatted_data+="<th>Actions</th>"
  #formatted_data+="</tr>"

  while IFS= read -r line; do
    IFS=";" read -ra fields <<< "$line"
    formatted_data+="<tr>"

    for ((i = 0; i < num_fields; i++)); do
      formatted_data+="<td>${fields[i]}</td>"
    done

    #formatted_data+="<td>&#9997; &#128465;</td>"
    #formatted_data+="</tr>"
  done < "$data_file"

  formatted_data+="</table>
    </body>
  </html>"

  echo "$formatted_data" > "$table_name/all.html"

  # Display the HTML using zenity --text-info
   xdg-open "$table_name/all.html" 2>>/dev/null
  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi
}

#function to select specific coulmn and their values from a given table
function Select_Columns() {

  current_dir=$(pwd)

  DB_name=$(basename "$current_dir")

  local Tables_list=$(ls "$current_dir/")
  
  selected_tb=$(zenity --list --width=300 --height=250  \
      --title="List of Tables in $DB_name.db" \
      --text="Choose a Table:" \
      --column="Tables" $Tables_list)

  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi

  local table_name="$selected_tb"
  local data_file="../$DB_name/$table_name/$table_name"

  headers=$(awk -F: 'NR>3 {print $1}' "$data_file.md")
  nf=$(awk -F: 'NR>3 {print NR-3":"$1}' "$data_file.md")
  wcl=$(awk ' END {print NR}' "$data_file")

  for header in $headers; do
    checklist_options+=(FALSE "$header")
  done

  selected_headers=$(zenity --list --width=300 --height=250  \
    --title="Columns" \
    --text="Choose the Columns you want to select :" \
    --checklist \
    --column="Check" \
    --column="Column" \
    "${checklist_options[@]}")
  checklist_options=()

  if [ $? -eq 0 ]; then
    IFS='|' read -ra selected_headers_array <<< "$selected_headers"
    selected_headers_table="<html>
    <head>
    <style>
      body {
        font-family: Arial, sans-serif;
      }
      table {
        border-collapse: collapse;
        width: 100%;
      }
      th, td {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
      }
      th {
        background-color: #f2f2f2;
      }
    </style>
    </head>
    <center>
    <body>
    <center>
      <h2>$table_name Table</h2>
    </center>
    <table>
      <tr>"

    field_indices=()
    for selected_header in "${selected_headers_array[@]}"; do
      selected_headers_table+="<th>$selected_header</th>"
      field_index=$(echo "$nf" | grep -n "$selected_header" | cut -d ":" -f 1)
      field_indices+=("$field_index")
    done

    #selected_headers_table+="<th>Actions</th>"
    #selected_headers_table+="</tr>"

    while IFS= read -r line; do
      IFS=";" read -ra fields <<< "$line"
      selected_headers_table+="<tr>"

      for field_index in "${field_indices[@]}"; do
        field_data=${fields[field_index-1]}
        selected_headers_table+="<td>$field_data</td>"
      done

      #selected_headers_table+="<td>&#9997; &#128465;</td>"
      #selected_headers_table+="</tr>"
    done < "$data_file"

    selected_headers_table+="</table>
    </body>
    </center>
    </html>"

    echo "$selected_headers_table" > "$table_name/columns.html"

xdg-open "$table_name/columns.html" 2>>/dev/null

    if [ $? -eq 1 ]; then
      Menu_Table "$DB_name"
    fi
  fi
  
  if [ $? -eq 1 ]; then
    Menu_Table "$DB_name"
  fi
}

#function that takes user input of displaying method for data in table 
function Select_Without_Condition() {
  local type=$1

  if [ "$type" == "All(*)" ]; then
    Select_All
  elif [ "$type" == "Columns" ]; then
    Select_Columns
  fi
}
