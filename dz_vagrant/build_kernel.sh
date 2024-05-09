sudo yum install -y git fakeroot make ncurses-devel xz xz-devel openssl-devel bc flex elfutils-libelf-devel bison
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.90.tar.xz -o ~/linux-6.1.90.tar.xz
tar xvf linux-6.1.90.tar.xz
cd  linux-6.1.90
cp -v /boot/config-6.8.9-1.el8.elrepo.x86_64 /home/vagrant/linux-6.1.90/.config
sudo make menuconfig
sudo make modules_install
sudo make install 