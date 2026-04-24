yay -S debtap
mkdir <package_name>
mv <package_name>.deb <package_name>/
cd <package_name>
sudo debtap -u
debtap -q <package_name>.deb
sudo pacman -U <package_name>.tar.zst
