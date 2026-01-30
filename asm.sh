#!/bin/bash

# =========================================
#   AMAN STORAGE MANAGER PRO
#   Author: Aman (Junoon Khan)
#   Email: junoon.khan17@gmail.com
# =========================================

# COLORS
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
C='\033[1;36m'
P='\033[1;35m'
W='\033[1;37m'
NC='\033[0m'

HOME_DIR="$HOME"
SD_PATH=$(ls /storage | grep -E '^[A-Z0-9]{4}-[A-Z0-9]{4}$' | head -n 1)
TOOLS_TMP="/tmp/asm_tools.txt"

pause(){ echo -e "${Y}Press Enter to continue...${NC}"; read; }

header(){
clear
echo -e "${P}"
echo "╔══════════════════════════════════════╗"
echo "║     AMAN STORAGE MANAGER PRO        ║"
echo "╠══════════════════════════════════════╣"
echo -e "║  ${C}Smart Termux Storage Control Tool${P}     ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"
}

scan_tools() {
    header
    echo -e "${C}🔍 Scanning heavy user folders (>50MB)...${NC}\n"
    > $TOOLS_TMP
    i=1
    for dir in "$HOME_DIR"/*; do
        name=$(basename "$dir")

        if [[ "$name" == .* ]] || [[ "$name" == "storage" ]]; then
            continue
        fi

        size=$(du -sm "$dir" 2>/dev/null | cut -f1)
        if [[ $size -gt 50 ]]; then
            echo -e "${G}$i) ${W}$name ${Y}— ${size}MB${NC}"
            echo "$name" >> $TOOLS_TMP
            ((i++))
        fi
    done
    pause
}

move_tool() {
    header
    if [ -z "$SD_PATH" ]; then
        echo -e "${R}❌ No SD card detected!${NC}"
        pause
        return
    fi

    mkdir -p /storage/$SD_PATH/TermuxTools
    scan_tools
    echo
    read -p "Enter tool number to MOVE: " num
    tool=$(sed -n "${num}p" $TOOLS_TMP)

    if [ -z "$tool" ]; then
        echo -e "${R}Invalid selection${NC}"
    else
        mv "$HOME_DIR/$tool" "/storage/$SD_PATH/TermuxTools/"
        echo -e "${G}✔ $tool moved to SD card successfully!${NC}"
    fi
    pause
}

delete_tool() {
    header
    scan_tools
    echo
    read -p "Enter tool number to DELETE: " num
    tool=$(sed -n "${num}p" $TOOLS_TMP)

    if [ -z "$tool" ]; then
        echo -e "${R}Invalid selection${NC}"
    else
        echo -e "${R}⚠ Are you sure you want to DELETE $tool?${NC}"
        read -p "(yes/no): " confirm
        if [[ "$confirm" == "yes" ]]; then
            rm -rf "$HOME_DIR/$tool"
            echo -e "${R}🗑 $tool deleted.${NC}"
        else
            echo -e "${Y}Cancelled.${NC}"
        fi
    fi
    pause
}

clean_cache() {
    header
    echo -e "${Y}🧹 Cleaning cache files...${NC}"
    pkg clean -y >/dev/null 2>&1
    apt clean -y >/dev/null 2>&1
    rm -rf ~/.cache/*
    find ~ -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null
    echo -e "${G}✔ Cache cleaned successfully!${NC}"
    pause
}

while true; do
header
echo -e "${B}1) 🔍 Scan Heavy User Tools${NC}"
echo -e "${B}2) 📦 Move Tool to SD Card${NC}"
echo -e "${B}3) 🗑 Delete Tool${NC}"
echo -e "${B}4) 🧹 Clean Cache${NC}"
echo -e "${B}0) 🚪 Exit${NC}"
echo
read -p "Choose an option: " choice

case $choice in
    1) scan_tools ;;
    2) move_tool ;;
    3) delete_tool ;;
    4) clean_cache ;;
    0) exit ;;
    *) echo -e "${R}Invalid option${NC}"; pause ;;
esac
done
