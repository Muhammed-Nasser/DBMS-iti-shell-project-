#! /bin/bash


# Choosing an option ( Home page / Starting menu )
function startView {
echo $'Choose an option: \n'
select menu in 'Create DB' 'List DB' 'Connect To DB' 'Drop DB' 'Exit'
do
	case $menu in
	'Create DB')
		echo $'\n'
		createDB
        ;;
	'List DB')
		echo $'\n'
		listDB
        ;;
	'Connect To DB')
		echo $'These are the current database:\n'
		listDB
		connectDB
        ;;
	'Drop DB')
		echo $'These are the current database:\n'
		listDB
		dropDB
        ;;
	'Exit')
		exitScript
        ;;
	*)
		echo $'\n'
		echo "Not valid choice!"
        ;;
	esac
done
}
function exitScript {
	echo $'OK, Bye !\n\n'
	exit
}

# <==={ Database Operation }===>
# Database creation if not existed
function createDB {
    echo $'Enter a name for the DB:\t'
    read database
    if ! [[ -d ./mydb/$database ]]
    then
        mkdir -p ./mydb/$database
        echo "$database created ... Done"
	else
	      echo "the $database is already exist"
	fi
}

# Database Delete 
function dropDB {
	echo $'Enter DB name to be deleted:\t'
	read database
	if [[ -d ./mydb/$database ]]
        then
	      rm -r ./mydb/$database
	      echo "$database removed ... Done"
	else 
	      echo "No matching name"	
		
	fi	
	      
}

#Listing Databases in the directory
function listDB {
	ls -1 ./mydb
	echo '' 
}



# Connect to an existing Database
function connectDB {

	echo $'Please Enter database name to connect it:\n'
	read database
	if [[ -d ./mydb/$database ]]
	then 
	       cd ./mydb/$database 2> /dev/null
	       echo 'Connected to' $database
		tablesOperation
	else 
		echo "no database with $database name"
		echo $'\nDo you want to create it? [y/n]\n'
		read answer
		case $answer in
			y)
			createDB;;
			n)
			connectDB;;
			*)
			echo "Incorect answer, Redirecting to main menu.." ;
			sleep 2
			startView;;	
		esac
	fi	
}


# <==={ Tables Operation }===>
function tablesOperation {
	echo $'Please choose an option: \n'
	select action in 'Create Table' 'List Tables' 'Drop Table' 'Insert into Table' 'Select From Table' 'Delete From Table' 		'Update Table' 'Main Menu' 'Exit'
		do
			case $action in
			'Create Table')
				createTable;;
			'List Tables')
				listTable;;
			'Drop Table')
				dropTable;;
			'Insert into Table')
				insertRecord;;
			'Select From Table')
				listTable
				selectRecord;;
			'Delete From Table')
				deleteRecord;;
			'Update Table')
				updateRecord;;
			'Main Menu')
				cd ../..
				startView;;
			'Exit')
				exitScript;;
			*)
				echo "Incorect answer, Redirecting to main menu.." ;
				cd ../..;
				sleep 2;
				startView;;
			esac
	done
}


# create table
function createTable {
	echo $'Please enter table name to create it: \n'
	read table
	
	if [[ -f $table ]]
	then 
		echo "table already exists!"
		cd ../..
		connectDB
	else
		touch $table
		echo "table created succesfully!"
	fi
	
	echo "Please enter Number of fields: "
	read fields
	num='^[0-9]+$'
	if  [[ $fields =~ $num ]]
	then 
		# PK flag
		flag="true"
		for (( i=1; i<=$fields; i++ ))
		do
			echo "Please enter name for field no.$i: "
			read colname
			# <------set PK------>
			while [ $flag == "true" ]
			do
				echo "Is this a PK? [Y/N]"
				read pk
				if [[ $pk == "Y" || $pk == "y" || $pk == "yes" ]]
				then
					flag="false"
					echo -n "(PK)" >> $table
				else
					break
				fi
			done
			
			# <------set col data type------>
			while true
			do 
				echo "Choose data type from (int , string)"
				read datatype
				case $datatype in
					int)
					echo -n $colname"($datatype);" >> $table;;
					string)
					echo -n $colname"($datatype);" >> $table;;
					*)
					echo "Data type incorrect!"
					continue;
				esac
				break
				
			done
	
		done
		
		echo $'\n' >> $table #end of table header
		echo "Your table $table created"
		tablesOperation
	else
		echo "$fields is not a valid input (numbers only)"
		sleep 2
		createTable
	fi	
}


#A similar fn to list files(tables) "each in a line"
function listTable {
	echo $'your current tables are:\n'
	ls -1
}

# Remove the table 
function dropTable {
	listTable
	echo $'Table name to be deleted:\t'
	read tablename
	
	if [[ -f $tablename ]]
	then 
		rm $tablename
		echo "$tablename is deleted!"	
	else
		echo "No matching table name"

	fi
}


function insertRecord {
	listTable
	echo "Please enter table name to insert data: "
	read table
	
	if [[ -f $table ]]
		then
			x=`grep 'PK' $table | grep -o ";" | wc -l` # no of fields
			
			for ((i=1;i <= x;i++)) 
			do      
				columnName=`grep PK $table | cut -f$i -d";"`
				echo $'\n'
				echo $"Please enter data for field no.$i [$columnName]"
				read data 
				checkType $i $data

				if [[ $? != 0 ]]
				then
					(( i = $i - 1 ))
				else	
					echo -n $data";" >> $table
				fi
			done	
			echo $'\n' >> $table #end of record
			echo "insert done into $table"
		else
			echo "Table doesn't exist"
			echo "Do you want to create it? [y/n]"
			read answer
			case $answer in
				y) createTable
					;;
				n) insertRecord
					;;
				*) echo "Incorrect answer. Redirecting to main menu.." ;
					sleep 2;
				cd ../..;
				startView
				;;
			esac
			
		fi
}


function selectRecord {
	echo "Please enter table name to select data: "
	read table
	if [[ -f $table ]]
	then
		echo $'\n'
			awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $table
			echo $'\nWould you like to print all records? [y/n]'
			read printall
			if [[ $printall == "Y" || $printall == "y" || $printall == "yes" ]]
			then
				echo $'\nWould you like to print a specific field? [y/n]'
				read cut1
				if [[ $cut1 == "Y" || $cut1 == "y" || $cut1 == "yes" ]]
				then
					echo $'\nPlease specify field number: '
					read fieldno
					echo $'<====================>'
					awk $'{print $0\n}' $table | cut -f$fieldno -d";"
					echo $'<====================>'
				else
					echo $'\n'
					echo $'<====================>'
					column -t -s ';' $table
					echo $'<====================>\n'
				fi
			else
				echo $'\nPlease enter a search value to select record(s): '
				read value
				echo $'\nWould you like to print a specific field? [y/n]'
				read cut
				if [[ $cut == "Y" || $cut == "y" || $cut == "yes" ]]
				then
					echo $'\nPlease specify field number: '
					read field
					echo $'<====================>\n'
					# find the pattern in records |> for that specific field
					awk -v pat=$value $'$0~pat{print $0\n}' $table | cut -f$field -d";"
					
				else
					echo echo $'<====================>\n'
					# find the pattern in records |> for all fields |> as a table display 
					awk -v pat=$value '$0~pat{print $0}' $table | column -t -s ';'
						
				fi
		fi
		echo $'\nWould you like to make another query? [y/n]'
		read answer
		if [[ $answer == "Y" || $answer == "y" || $answer == "yes" ]]
		then
			
			selectRecord
		elif [[ $answer == "N" || $answer == "n" || $answer == "no" ]]
		then	
			
			cd ../..
			connectDB
		else
			echo $'Invalid choice\n'
			echo "Redirecting to main menu.."
			cd ../..
			sleep 2
			startView
		fi
	else
		echo "Table doesn't exist"
		echo "Do you want to create it? [y/n]"
		read answer
		case $answer in
			y)
			createTable;;
			n)
			selectRecord;;
			*)
			echo "Incorrect answer. Redirecting to main menu.." ;
			sleep 2;
			cd ../..;
			startView;;
		esac
	fi
}


# Delete Record steps
# 1. list all records => PK
# 2. check PK to delete its record
# [ file => copyFile 		]
# | clear file				|
# [ copyFile =Filter=> file	]
function deleteRecord {
	echo "Please enter table name to delete from: "
	read table
	if [[ -f $table ]]
	then
			awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $table
			echo  "Enter Column name:"
			read field

			## get the field number
			findex=$(awk 'BEGIN{FS=";"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $table )
			if [[ $findex == "" ]]
			then
				echo "Not Found"
				tablesOperation
			else
				echo "Enter Value:"
				read value
				res=$(awk 'BEGIN{FS=";"}{if ($'$findex'=="'$value'") print $'$findex'}' $table 2>> /dev/null)

				if [[ $res == "" ]]
				then
					echo "Value Not Found"
					tablesOperation
				else
					# get the record number to be deleted
					NR=$(awk 'BEGIN{FS=";"}{if ($'$findex'=="'$value'") print NR}' $table 2>> /dev/null)

					sed -i ''$NR'd' $table 2>> /dev/null
					echo "Row Deleted Successfully"
					tablesOperation
				fi
			fi
	else
		echo "Table doesn't exist"
	fi
}

function updateRecord {
	echo "Enter Table Name:"
	read table
	awk 'BEGIN{FS=";"}{if (NR==1) {for(i=1;i<=NF;i++){printf "--|--"$i}{print "--|"}}}' $table
	echo "Enter Column name: "
	read field
	findex=$(awk 'BEGIN{FS=";"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i }}}' $table )
	if [[ $findex == "" ]]
	then
		echo "Not Found"
		tablesOperation
	else
		echo "Enter Value:"
		read value
		result=$(awk 'BEGIN{FS=";"}{if ($'$findex'=="'$value'") print $'$findex'}' $table 2>> /dev/null)
		if [[ $result == "" ]]
		then
		echo "Value Not Found"
		tablesOperation
		else
			echo "Enter new Value to set:"
			read newValue
			NR=$(awk 'BEGIN{FS=";"}{if ($'$findex' == "'$value'") print NR}' $table 2>> /dev/null)
			echo $NR
			oldValue=$(awk 'BEGIN{FS=";"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$findex') print $i}}}' $table 2>> /dev/null)
			echo $oldValue
			sed -i ''$NR's/'$oldValue'/'$newValue'/g' $table 2>> /dev/null
			echo "Row Updated Successfully"
			tablesOperation
		fi
	fi
}

# checktype fieldno. data_for_that_field
function checkType {
	datatype=`grep PK $table | cut -f$1 -d";"`

	# colname(int) => get in the () only
	if [[ "$datatype" == *"int"* ]]
	then
		num='^[0-9]+$'
		if ! [[ $2 =~ $num ]]
		then
			echo "False input: Not a number!"
			return 1
		else
			checkPK $1 $2
		fi
	elif [[ "$datatype" == *"string"* ]]
	then
		str='^[a-zA-Z]+$'
		if ! [[ $2 =~ $str ]]
		then
			echo "False input: Not a valid string!"
			return 1
		else
			checkPK $1 $2
		fi
	fi
}

# checkPrimaryKeyExistance fieldno. data_for_that_field

function checkPK {
header=`grep PK $table | cut -f$1 -d";"`
if [[ "$header" == *"PK"* ]]
then
	if [[ `cut -f$1 -d";" $table | grep -w $2` ]]
	then
		echo $'\nPrimary Key already exists. no duplicates allowed!' 
		return 1
	fi
fi
}



startView
