#!/usr/bin/bash

echo "zig-select"

function assign_or_echo() {
    local __value_ref=$1;
    local __result_ref=$2;
    if [[ "$__result_ref" ]]; then
        eval $__result_ref="'$__value_ref'"
    else
        echo "$__value_ref" #"echo '$__value_ref'"
    fi
}

# function fn() {
#     local __state=$1;
#     local __func_name=$2;
#     local result_name="local __$__func_name\_result="
# }

function get_zig_version_archives() {
    #should make sure they have awk, but I do so I will not do that rn;
    local __result=$1;
    local archives=$(ls | awk '/zig-.+\.zip/ {print $NF}');
    assign_or_echo "$archives" "$__result"
}

function remove_suffix() {
    local __input="$1";
    local __suffix=$2;
    local __result=$3
    local var=$(echo "$__input" | awk "{gsub(\"$__suffix\", \"\");print}")
    assign_or_echo "$var" "$__result"
}


function select_avaliable_zig_versions() {
    echo "Please select which version of Zig you would like to use:"
    local zig_versions=$(remove_suffix "$(get_zig_version_archives)" ".zip");
    local index=0;
    local selection=;
    for version in $zig_versions; do
        echo "$index: $version";
        index=$((index+1))
    done

    read -p "version [0-$((index-1))]: " selection

    if ! [ $selection -eq $selection 2> /dev/null ]; then
            echo "Error!: '$selection' is not a number! ,please input a number between 0 and $((index-1))" && exit;
    fi

    if [[ "$selection" -gt "$index" ]]; then
        echo "Error!: '$selection' is not a valid selection, please input a number between 0 and $((index-1))" && exit;
    fi

    local zig_versions_list=($zig_versions);
    # echo ${#zig_versions_list[@]}
    # for i in "${#zig_verisons_list[@]}"; do
    #     echo $i;
    # done

    local selected_version="${zig_versions_list[$(($selection))]}"
    echo;
    echo "You selected: $selected_version"
    if ! [[ -d "./$selected_version" ]]; then
        echo "unzipping:" && 7z x -o"./$selected_version" "$selected_version.zip";
    else
        echo "$selected_version has already been extracted, moving on."
    fi


    echo "Clearing current zig version folder."
    local zig_current_files=$(ls -A "./zig-current"| awk '{print $NF}');
    for file in $zig_current_files; do
        echo "-@@ Clearing File : $file @@-";
        rm -r "./zig-current/$file";
    done


    echo "setting current zig version to $selected_version.";
    local selected_version_files=$(ls -A "./$selected_version/$selected_version" | awk '{print $NF}');
    for file in $selected_version_files; do
        echo "+@@ Copying File: $file @@+";
        cp -r "./$selected_version/$selected_version/$file" "./zig-current/$file";
    done
    #cp "./$selected_version/$selected_version/*" "./zig-current/"
}

#save current directory
#change to zig_versions_dir
#execute
#return
select_avaliable_zig_versions