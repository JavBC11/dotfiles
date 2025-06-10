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
user=$(whoami)
dotfiles_dir="$dir/.config"
dotfile_zsh="$dir/"
dotfile_bin="$dir/bin"

trap ctrl_c INT

function ctrl_c() {
	echo -e "\n\n${redColour}[!] Exiting...\n${endColour}"
	exit 1
}

if [ "$user" == "root" ]; then
	echo -e "\n\n${redColour}[!] You should not run the script as the root user!\n${endColour}"
	exit 1
else
	sleep 1
	echo -e "\n\n${blueColour}[*] Installing necessary packages\n${endColour}"
	sleep 2
	sudo pacman -Syu --noconfirm
	sudo pacman -S --noconfirm bat blueman brightnessctl fastfetch git htop hyprlock hyprpaper lsd nautilus nwg-look neovim pamixer papirus-icon-theme pavucontrol python-pip python-distutils-extra rofi-wayland ttf-font-awesome ttf-jetbrains-mono ttf-jetbrains-mono-nerd waybar zsh zsh-autosuggestions zsh-syntax-highlighting
	if [ $? != 0 ] && [ $? != 130 ]; then
		echo -e "\n${redColour}[-] Failed to install some packages!\n${endColour}"
		exit 1
	else
		echo -e "\n${greenColour}[+] Done installing necessary packages...\n${endColour}"
		sleep 1.5
	fi

	echo -e "\n${blueColour}[*] Starting installation of necessary dependencies for the environment...\n${endColour}"
	sleep 0.5

	echo -e "\n${purpleColour}[*] Installing necessary dependencies of pip\n${endColour}"
	sleep 2
	pip install psutil gputil pyamdgpuinfo inquirer loguru pyyaml colorama --break-system-packages
	if [ $? != 0 ] && [ $? != 130 ]; then
		echo -e "\n${redColour}[-] Failed to install some dependencies for pip\n${endColour}"
		exit 1
	else
		echo -e "\n${greenColour}[+] Done pip depedencies...\n${endColour}"
		sleep 1.5
	fi

	# Installing yay & packages
	if ! command -v yay &>/dev/null; then
		echo -e "\n${purpleColour}[*] Installing yay...${endColour}"
		sudo pacman -S --needed --noconfirm git base-devel
		git clone https://aur.archlinux.org/yay.git ~/yay && (cd ~/yay && makepkg -si --noconfirm) && rm -rf ~/yay
	fi
	echo -e "\n${greenColour}[+] Done installation of yay...\n${endColour}"
	sleep 1.5

	echo -e "\n${purpleColour}[*] Installing package with yay${endColour}"
	yay -S --noconfirm hyprshot bibata-cursor-git catppuccin-gtk-theme-mocha
	echo -e "\n${greenColour}[+] Done installation yay package...\n${endColour}"
	sleep 1.5

  #zsh config
	echo -e "\n${purpleColour}[*] Installing Oh My Zsh to user $user...\n${endColour}"
	sleep 2
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
	if [ $? != 0 ] && [ $? != 130 ]; then
		echo -e "\n${redColour}[-] Failed to install Oh My Zsh $user!\n${endColour}"
		exit 1
	else
		echo -e "\n${greenColour}[+] Done installing Oh My Zsh...\n${endColour}"
		sleep 1.5
	fi

  #copy configs
	echo -e "\n${blueColour}[*] Copy configs to ~/.config${endColour}"
	config_dirs=(dunst fastfetch gtk-3.0 gtk-4.0 hypr kitty waybar nvim rofi)
	for dir in "${config_dirs[@]}"; do
		mkdir -p "$HOME/.config/$dir"
		cp -r "$dotfiles_dir/$dir"/* "$HOME/.config/$dir/"
	done
	echo -e "\n${greenColour}[+] Done Copy configs...\n${endColour}"
	sleep 1.5

	echo -e "${blueColour}[*] Coping .zshrc & change shell${endColour}"
	cp $dotfile_zsh/.zshrc $HOME
	chsh -s /bin/zsh
	echo -e "${greenColour}[+] Done moving .zshrc & change shell for zsh...${endColour}"
	sleep 1.5

	echo -e "\n${blueColour}[*] Copy directory bin${endColour}"
	cp -r "$dotfile_bin" "$HOME"
	echo -e "\n${greenColour}[+] Done copy directory bin to $HOME...\n${endColour}"
	sleep 1.5

	while true; do
		echo -en "\n${yellowColour}[?] It's necessary to restart the system. Do you want to restart the system now? ([y]/n) ${endColour}"
		read -r
		REPLY=${REPLY:-"y"}
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			echo -e "\n\n${greenColour}[+] Restarting the system...\n${endColor}"
			sleep 1
			sudo reboot
		elif [[ $REPLY =~ ^[Nn]$ ]]; then
			exit 0
		else
			echo -e "\n${redColour}[!] Invalid response, please try again\n${endColour}"
		fi
	done
fi
