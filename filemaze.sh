#!/usr/bin/env bash

python3_env=false
target_file="mazeEnd"
starting_file="file0"
max_dirs=10
num_files=10
file_locations=()

set_python(){
    
    if command -v python3 &>/dev/null; then
        echo "Python3 is installed"
        python3_env=true
    fi

}

change_default_path()
{
    read -p "Enter the target file for the maze exit" target_file
}

create_maze(){

    touch file0
    read -p "Enter the number of files to be created in the maze: " num_files
    read -p "Enter the maximum number of directories:" max_dirs

    if test -e "$target_file"; then
        echo "creating maze at $starting_file targeting $target_file"
    else
        touch $target_file
        echo "creating maze at $starting_file targeting $target_file"
    fi 
     
    for letter in {a..z}; do
        path="mazeEntrance"

        # Check if Python is installed
        if $python3_env; then
            path="mazeEntrance$(python3 -c 'print("/'$letter'" * '$max_dirs')')"
        else
            for ((i=1; i<=$max_dirs; i++)); do
                path="${path}/$letter"
            done
        fi
        mkdir -p "$path"
        unset path
    done
        
    # Create files in maze directories randomly and save their paths to an array
    for ((i=1; i<=$num_files; i++)); do
        # Generate a random alphabet character
        random_alphabet=$(echo $((RANDOM%26+97)) | awk '{printf "%c", $0}')

        # Generate a random value between 0 and max_dirs-1 (inclusive)
        random_value=$((RANDOM%max_dirs))

        # Generate random path to file
        path_temp="mazeEntrance"

        if $python3_env; then
            path_temp="mazeEntrance$(python3 -c 'print("/'$random_alphabet'" * '$random_value')')"
        else
            for ((j=1; j<=random_value; j++)); do
                path_temp="${path_temp}/$random_alphabet"
            done
        fi


        # save file locations
        file_locations+=("$path_temp/file$i")

        # Create symbolic link to the previous file
        if ((i > 1)); then
            prev_file="${file_locations[i-2]}"
            ln -s "$prev_file" "${path_temp}/file$i"
        elif ((i == max_dirs)); then
            ln -s "${file_locations[i-1]}" "$starting_file"
        else
            ln -s "$target_file" "${file_locations[i-1]}"
        fi
    done

    unset random_value random_alphabet path_temp prev_file
}

remove_maze(){
    rm -r $starting_file
    rm -rf mazeEntrance
    rm mazeEnd
    unset file_locations 
}


print_symbolic_links() {
    echo "Symbolic links:"
    for link in "${file_locations[@]}"; do
        echo "$link"
    done
}

while true; do
    echo "------------------------"
    echo "Menu:"
    echo "1. Set Python"
    echo "2. Link to File"
    echo "3. Create Maze"
    echo "4. Print Symbolic Links"
    echo "5. Remove maze"
    echo "6. exit"

    read -p "Enter your choice (1-6): " choice

    case $choice in
        1)
            set_python
            ;;
        2)
            change_default_path
            ;;
        3)
            create_maze
            ;;
        4)
            print_symbolic_links
            ;;
        5)
            remove_maze
            ;;
        6)
            break
            ;;
    esac
done