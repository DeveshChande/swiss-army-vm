apt update && apt -y upgrade
sudo -u packer env XDG_RUNTIME_DIR=/run/user/$(id -u packer) xdg-user-dirs-update
