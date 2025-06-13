#!/usr/bin/bash

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"

# Global variables
dir=$(pwd)
dotfiles_dir="$dir/.config"
dotfile_bin="$dir/bin"
packages=(bat blueman brightnessctl cava dunst fastfetch feh flatpak git htop hyprland hyprlock hyprpaper kitty lsd nautilus nwg-look neovim pamixer papirus-icon-theme pavucontrol python-pip python-distutils-extra qt5-wayland qt6-wayland rofi-wayland ttf-font-awesome ttf-jetbrains-mono ttf-jetbrains-mono-nerd wget waybar xdg-desktop-portal-hyprland xdg-utils yazi zsh zsh-autosuggestions zsh-syntax-highlighting)

trap ctrl_c INT

function ctrl_c() {
	echo -e "\n\n${redColour}[!] Exiting...\n${endColour}"
	exit 1
}

if [ "$EUID" -eq 0 ]; then
	echo -e "\n\n${redColour}[!] You should not run the script as the root user!\n${endColour}"
	exit 1
else
	sleep 1
	echo -e "\n\n${blueColour}[*] Installing necessary packages\n${endColour}"
	sudo pacman -Syu --noconfirm 
  for pkg in "${packages[@]}"; do
    echo -ne "${yellowColour}[*] Verifying package: $pkg...${endColour} "
    
    if pacman -Si "$pkg" &>/dev/null; then
      echo -e "${greenColour}[FOUND]${endColour}"
      if ! sudo pacman -S --noconfirm "$pkg"; then
        echo -e "${redColour}[-] Failed to install: $pkg${endColour}"
        exit 1
      fi
    else
      echo -e "${redColour}[NOT FOUND]${endColour}"
      echo -e "${redColour}[-] Package '$pkg' not found in repositories. Exiting.${endColour}"
      exit 1
    fi
  done
  echo -e "\n${greenColour}[+] All packages installed successfully.${endColour}"

	echo -e "\n${purpleColour}[*] Installing necessary dependencies of pip\n${endColour}"
	pip install psutil gputil pyamdgpuinfo inquirer loguru pyyaml colorama --break-system-packages
	if [ $? != 0 ] && [ $? != 130 ]; then
		echo -e "\n${redColour}[-] Failed to install some dependencies for pip\n${endColour}"
		exit 1
	else
		echo -e "\n${greenColour}[+] Done pip depedencies...\n${endColour}"
	fi

	# Installing yay & packages
	if ! command -v yay &>/dev/null; then
		echo -e "\n${purpleColour}[*] Installing yay...${endColour}"
		sudo pacman -S --needed --noconfirm git base-devel
		git clone https://aur.archlinux.org/yay.git ~/yay && (cd ~/yay && makepkg -si --noconfirm) && rm -rf ~/yay
	fi
	echo -e "\n${greenColour}[+] Done installation of yay...\n${endColour}"

	echo -e "\n${purpleColour}[*] Installing package with yay${endColour}"
	yay -S --noconfirm hyprshot bibata-cursor-git catppuccin-gtk-theme-mocha
	echo -e "\n${greenColour}[+] Done installation yay package...\n${endColour}"

  #install zsh and conf
  echo -e "\n${purpleColour}[*] Do you want to install Oh My Zsh? ([Y]/n)${endColour}"
  read -r install_omz
  install_omz=${install_omz:-"y"}
  
  if [[ "$install_omz" =~ ^[Yy]$ ]]; then
    echo -e "\n${purpleColour}[*] Installing Oh My Zsh for user $user...\n${endColour}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  
    if [ $? -ne 0 ]; then
      echo -e "\n${redColour}[-] Failed to install Oh My Zsh for $user!\n${endColour}"
      exit 1
    else
      echo -e "\n${greenColour}[+] Done installing Oh My Zsh...\n${endColour}"
    fi
  
    echo -e "\n${yellowColour}[?] Do you want to copy your custom .zshrc config? ([Y]/n)${endColour}"
    read -r copy_zshrc
    copy_zshrc=${copy_zshrc:-"y"}
  
    if [[ "$copy_zshrc" =~ ^[Yy]$ ]]; then
      cp "$pwd/.zshrc" "$HOME"
      echo -e "${greenColour}[+] .zshrc copied to $HOME${endColour}"
    else
      echo -e "${blueColour}[*] Skipped copying .zshrc${endColour}"
    fi
  else
    echo -e "${blueColour}[*] Skipped Oh My Zsh installation${endColour}"
  fi
  
  echo -e "\n${yellowColour}[?] Do you want to change your default shell to zsh? ([Y]/n)${endColour}"
  read -r change_shell
  change_shell=${change_shell:-"y"}
  
  if [[ "$change_shell" =~ ^[Yy]$ ]]; then
    chsh -s /bin/zsh
    echo -e "${greenColour}[+] Default shell changed to zsh for user $user${endColour}"
  else
    echo -e "${blueColour}[*] Skipped changing default shell${endColour}"
  fi

  #copy .config & create backup
  echo -e "\n${blueColour}[*] Backing up and copying configs to ~/.config${endColour}"
  
  config_dirs=(dunst fastfetch gtk-3.0 gtk-4.0 hypr kitty waybar nvim rofi)
  backup_dir="$HOME/backup/$(date +%Y%m%d_%H%M%S)"
  
  mkdir -p "$backup_dir"
  
  for dir in "${config_dirs[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
      echo -e "${yellowColour}[*] Backing up existing $dir to $backup_dir${endColour}"
      mkdir -p "$backup_dir/$dir"
      cp -r "$HOME/.config/$dir/"* "$backup_dir/$dir/"
    fi
  
    echo -e "${blueColour}[*] Installing config: $dir${endColour}"
    mkdir -p "$HOME/.config/$dir"
    cp -r "$dotfiles_dir/$dir/"* "$HOME/.config/$dir/"
  done
  
  echo -e "\n${greenColour}[+] Done backing up and copying configs to ~/.config${endColour}"

  #directory bin, for some modules of waybar and rofi
	echo -e "\n${blueColour}[*] Copy directory bin${endColour}"
	cp -r "$dotfile_bin" "$HOME"
	echo -e "\n${greenColour}[+] Done copy directory bin to $HOME...\n${endColour}"

	while true; do
		echo -en "\n${yellowColour}[?] It's necessary to restart the system. Do you want to restart the system now? ([y]/n) ${endColour}"
		read -r
		REPLY=${REPLY:-"y"}
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo -e "\n\n${greenColour}[+] Restarting the system...\n${endColour}"
			sleep 1
			sudo reboot
		elif [[ $REPLY =~ ^[Nn]$ ]]; then
			exit 0
		else
			echo -e "\n${redColour}[!] Invalid response, please try again\n${endColour}"
		fi
	done
fi
