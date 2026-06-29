# ussh_install.sh README.md

A bash script that syncs a Raspberry Pi's clock from a connected host computer over SSH, for use when the Pi has no internet access and no real-time clock module.

## Why

A Raspberry Pi without a real-time clock (RTC) module loses track of time when powered off, since it has no battery-backed clock. If the Pi is also offline (no NTP server reachable), its clock drifts and file timestamps become unreliable. This script syncs the Pi's clock from the host computer at the moment of connection.

## Security notice

This repo contains shell scripts that run on your machine and on your Raspberry Pi. Before running anything from this repo, please:

1. Read `ussh_install.sh` end-to-end to understand what the installer does.
2. Read `ussh` (the script the installer creates) to understand what runs when you connect to the Pi.
3. Avoid `curl ... | bash`-style installs without first downloading and reviewing the script.

The installer writes a file to your chosen directory, optionally generates an SSH keypair, and prints instructions for connecting to the Pi. It does not modify system files or install anything that requires root on your host machine.

## Requirements

**Host machine:**
- Ubuntu Linux (20.04 and 24.04)
- `ssh`, `ssh-keygen`, `ssh-copy-id` available (standard on Ubuntu)
- `bash` (standard on Ubuntu)

**Raspberry Pi:**
- Username `ubuntu` (hardcoded in the script — change manually if yours differs)
- IP `10.42.0.1` (the default NetworkManager hotspot gateway — hardcoded; change manually if yours differs)
- SSH server enabled on the Pi
- User account with `sudo` access (needed to set the system clock)

**Network:**
- A way for the host to reach the Pi at `10.42.0.1` — typically the Pi runs its own WiFi hotspot and the host joins it
- Note: while connected to the Pi's hotspot, the host may not have internet access

## Install (automatic)

The installer handles the steps in the manual install section — creating the directory, writing the `ussh` script, optionally generating an SSH key.

**Recommended — download, review, run:**

```bash
curl -O https://raw.githubusercontent.com/ingenium-lidar/RFCs/refs/heads/main/Request%20For%20Software/RFS1%20-%20RPi%20Clock%20Sync/ussh_install.sh
less ussh_install.sh
bash ussh_install.sh
```

For a quicker setup (after previously reviewing the script:

```bash
curl -fsSL https://raw.githubusercontent.com/ingenium-lidar/RFCs/refs/heads/main/Request%20For%20Software/RFS1%20-%20RPi%20Clock%20Sync/ussh_install.sh
```

The installer will prompt you for:
- Install location (`~/bin` or a custom directory)
- Whether to set up an SSH key (and if so, `ssh-keygen` will prompt for the key location and passphrase)

It's safe to re-run — existing files are skipped, not overwritten.

To perform manually, see [Ubuntu Linux Manual Installation](##ubuntu-linux-manual-installation)

## Usage

Once installed, connect to the Pi's hotspot, then run:

```bash
ussh
```

You'll be prompted for your key passphrase (if set up) or the Pi's password (if not). On success, the Pi's clock is synced to your host machine and you're dropped into an interactive Pi shell.

## Limitations

- Hardcoded `ubuntu@10.42.0.1` — won't work for Pis configured differently without manual edits.
- The `sudo date -s` call on the Pi may prompt for a password over SSH and hang in non-interactive scenarios. If you hit this, you can configure passwordless `sudo` for `/bin/date` only on the Pi via `visudo` — but this is a Pi-side change with security implications worth understanding first.
- The Pi must be booted and reachable on the hotspot before `ussh` will work.

## Ubuntu Linux Manual Installation
To install manually:

  1. First, starting in the right Ubuntu distro (this process will work for both Ubuntu 20.04 and 24.04), you will have to decide where you want this file to be created. I did it in my ~/bin which adds it to my $PATH, which is mostly useful in that you don't need to be in a particular file to run it.
  - If you are using ~/bin to add to PATH, first check if you have it set up with: 
```bash
echo $PATH
```
  - If it doesn't appear, then create it:
```bash
mkdir -p ~/bin #mkdir = make directory, -p = plan for errors
```
  - Then check again with:
```bash
echo $PATH
```
  2. From here, if you chose to add to $PATH, then use the following syntax to create a file in your $PATH, otherwise use the directory you chose in place here:
```bash
touch ~/bin/ussh
```
  3. Next, make the file executable with:
```bash
chmod +x ~/bin/ussh
```
  4. From here, we can create the contents of the file by first opening an editor. I will show a couple of ways to do it within the editor, but also know you can use VS Code (which would use code ~/bin/ussh) or any other editor.
    - So the first way is to use the nano command:
```bash
nano ~/bin/ussh
```
  5. Now you can work in this editor and write in the new ussh script:
```bash
#!/bin/bash #This is a shebang. Present in every bash script.
current_host_datetime=$(date "+%Y-%m-%d %H:%M:%S") #This creates a variable "current_host_datetime" which reads the datetime of the computer and puts it in the format Year-month-day Hour:Minute:Second
ssh ubuntu@10.42.0.1 "sudo date -s \"$current_host_datetime\"" #This command in an ssh into the RPi (at ubuntu@10.42.0.1) using the admin (sudo) command, which updates the RPi's time to the variable we just created in the last line.
ssh ubuntu@10.42.0.1 #This is a second ssh to actually get into the RPi and allow further access to it.
```
  - Save with Ctrl "O" and close the nano terminal with Ctrl "X".
  5. (Alternate) Another method to do this is to use no terminal at all using a heredoc. To do this, simply paste the following into the terminal:
```bash
cat > ~/bin/ussh << 'EOF' #"cat" stands for "concatenate" and doesn't do much, but it allows us to write this heredoc (short for "here document") into a file. "<<EOF" bookends with the final "EOF" to define this heredoc.
#!/bin/bash
current_host_datetime=$(date "+%Y-%m-%d %H:%M:%S")
ssh ubuntu@10.42.0.1 "sudo date -s \"$current_host_datetime\""
ssh ubuntu@10.42.0.1
EOF #Bookends with "<< EOF" to define the heredoc.
```
  6. Congratulations! You have successfully installed an SSH script that syncs your RPi clock on first connection.
# Optional: Use Key and Passphrase to streamline connection.
  1. You now have a working ssh, however you will have to enter the RPi password for each ssh request in the ussh script (there are two). You can do this no problem, but if you want to streamline this to only one, then you will want to create a key and passphrase.
      - To begin, write the following in the terminal:
```bash
ssh-keygen -t ed25519 #"ssh-keygen" generates a new key, "-t" specifies the type of key to be generated which is "ed25519".
```
  - For the key, "ed25519" is most recommended, but here are some other common encription options:
    
<img width="1231" height="286" alt="image" src="https://github.com/user-attachments/assets/3097b199-0f93-410e-b48b-139eb6b1e4f9" />
    
  - You will be automatically prompted a couple of times. First to confirm location, confirm location at "~/.ssh/id_ed25519", which should be listed and you just hit enter. Second, to enter a passphrase 
  2. You can check that it worked by writing this:
```bash
ls -la ~/.ssh/ # ls (list) -la (lists all files (-a) in a long format (-l))
```
  - If you see "id_ed25519" and "id_ed25519.pub" (the first being a private and teh second a public key) then you are all set!
  3. You now have a key and passphrase! Now to connect it to the RPi, you write the following when it boots:
```bash
ssh-copy-id ubuntu@10.42.0.1
```
# To use on Ubuntu Linux
  1. This should fully set up the RPi Clock Sync on a Ubuntu Linux System (20.04 or 24.04) and should run automatically upon first ssh connection. To run, type the command:
```bash
ussh
```
  - When you run the ssh in the terminal. You will be prompted for your password (or passwords if you didn't create a key and passphrase).
  2. If you did everything right, you should have a synced clock on the RPi!
