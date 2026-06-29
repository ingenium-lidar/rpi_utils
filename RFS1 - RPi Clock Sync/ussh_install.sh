#!/bin/bash
while true; do #MS Starts while loop which determines whether we install in ~/bin or in a custom directory.
    read -r -p "Do you want to add to \$PATH (type \"1\") or to a custom directory (type \"2\")? " script_location 
    if [[ "$script_location" == "1" ]]; then #MS This if statement will mark the location to ~/bin if "1" is selected.
        target_dir="$HOME/bin"
        break
    elif [[ "$script_location" == "2" ]]; then #MS This elif will further prompt for a custom directory if "2" is selected.
        echo "A custom directory will not be added to \$PATH, but can be added manually by the user later."
        while true; do #MS Loops until valid inputted directory is located.
            read -r -p "Please enter your desired directory path: " custom_path
            if [[ -d "$custom_path" ]]; then #MS Checks if custom_path exists and if so, proceeds.
                target_dir="$custom_path"
                break 2
            else #MS Asks the user to try again if the location is invalid.
                echo "That directory is invalid. Please try again."
            fi
        done
    else #MS If the user enters something other than "1" or "2" the system doesn't error and instead re-prompts.
        echo "Please enter a valid input."
    fi
done

mkdir -p "$target_dir" #MS We now make a home in the directory for this script to be installed. "-p" prevents the command from erroring if "ussh" already exists.

if [[ -f "$target_dir/ussh" ]]; then #MS Checks for already existing file with this name (did we install previously and, if so, does not overwrite).
    echo "ussh exists. Skipping..."
else #MS if not, we are all good and can proceed with installation of script.
    cat > "$target_dir/ussh" << 'EOF' #MS A heredoc that writes to target_dir/ussh.
#!/bin/bash
current_host_datetime=$(date "+%Y-%m-%d %H:%M:%S") #MS Identifies current host date and time.
ssh ubuntu@10.42.0.1 "sudo date -s \"$current_host_datetime\"" #MS Performs SSH into the RPi using sudo, corrects time of RPi, and disconnects connection.
EOF
    chmod +x "$target_dir/ussh" #MS "chmod +x" makes the file executable.
fi

echo "Note this is not an ssh. Please ssh separately"

read -r -p "Do you want to set up an SSH key? Y/N " key_binary #MS At this point, the user will have to enter the RPi password twice. A minor inconvenience, but if they would like, they can generate and setup an SSH key to streamline the double SSH with one passphrase.
if [[ "$key_binary" =~ ^[Yy] ]]; then #MS If the above input yields anything that starts with "y" or "Y", the setup will proceed.
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then #MS Check if key already exists and if so, skip.
        echo "Key already exists. Skipping step..."
        key_setup=true
    else #MS Otherwise we generate the key and passphrase.
        ssh-keygen -t ed25519
        key_setup=true
    fi
else #MS If the user wants to skip key generation, we skip.
    echo "Ok, skipping key generation."
    key_setup=false
fi

if [[ "$key_setup" == "true" ]]; then #MS If the user generated a key and passphrase, then they will need to configure the RPi afterwards. 
    echo "Connect to the Pi's hotspot, then run ssh-copy-id ubuntu@10.42.0.1. Then run ussh."
else #MS If they skip key and passphrase, then they can proceed to use "ussh"!
    echo "Connect to the Pi's hotspot, then run ussh. It will prompt for the Pi's password."
fi
