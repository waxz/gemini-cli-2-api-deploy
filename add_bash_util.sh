
# gh_install vi/websocat websocat.x86_64-unknown-linux-musl
gh_install() {
  echo "Number of arguments: $#"
  echo "All arguments as separate words: $@"
  echo "All arguments as a single string: $*"

  if [[ $# -ne 3 ]]; then
    echo "Please set repo, arch, and filename"
    return 1
  fi

  local repo="$1"
  local arch="$2"
  local filename="$3"

  echo "Set repo: $repo, arch: $arch, filename: $filename"

  local url
  local count=0

  while [[ -z "$url" && $count -lt 5 ]]; do
    content=$(curl -s -L -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$repo/releases")
    url=$(echo "$content" | jq -r --arg arch "$arch" '.[0] | .assets[] | .browser_download_url | select(endswith($arch))')
    count=$((count + 1))
  done

  if [[ -z "$url" ]]; then
    echo "Failed to find a valid download URL after $count attempts."
    return 1
  fi

  echo "Download URL: $url"
  wget -q "$url" -O "$filename" && echo "Downloaded $filename successfully." || echo "Failed to download $filename."
}

check_installed() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: check_installed <program_name>"
        return 1
    fi
    if which "$1" &>/dev/null; then
        >&2 echo "$1 is installed"
        >&1 echo 0
    else
        >&2 echo "$1 is not installed"
        >&1 echo 1
    fi
}
# check_installed docker  1>/dev/null
# check_installed docker  2>/dev/null
# check_installed docker  &>/dev/null


# Utility functions for managing processes
ps_kill() {
  echo "Number of arguments: $#"
  echo "All arguments as separate words: $@"
  echo "All arguments as a single string: $*"

  if [[ $# -ne 1 ]]; then
    echo "Please set program"
    return 1
  fi
  program="$1"

  ps -A -o tid,cmd  | grep -v grep | grep "$program" | awk '{print $1}' | xargs -I {} /bin/bash -c 'sudo kill -9  {} '
}

install_docker() { 
    if ! which docker &>/dev/null; then
        echo "Docker is not installed. Installing..."
        curl -fsSL https://get.docker.com | sh
        sudo systemctl --now enable docker
        echo "Docker installed successfully."
    else
        echo "Docker is already installed."
    fi
}

create_user() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: create_user <username>"
        return 1
    fi
    export USERNAME="$1"
    export MUID=$(id -u)
    export MGID=$(id -g)

    # add user without password

    sudo groupadd $USERNAME
    # same uid with host user
    # sudo useradd -u $MUID -g $MGID -m -s /bin/bash $USERNAME
    sudo useradd  -g $MGID -m -s /bin/bash $USERNAME
    sudo passwd -d $USERNAME
    sudo usermod -a -G sudo $USERNAME
    sudo usermod -a -G $USERNAME $USERNAME

    install_docker
    sudo usermod -a -G docker $USERNAME


    echo "User $USERNAME created and added to sudo and docker groups."
}

# reset cursor
# https://unix.stackexchange.com/questions/6890/what-is-making-my-cursor-randomly-disappear-when-using-gnome-teminal
tput cnorm