#!/bin/bash
echo "Making swapfile..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo $'\n/swapfile swap swap defaults 0 0\n' | sudo tee -a /etc/fstab > /dev/null
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release rsync
curl -fsSL https://get.docker.com | sudo bash -s
sudo apt-get -y install docker-compose
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get -y install docker-ce docker-ce-cli containerd.io
# sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
echo "Initializing server, this might take a few minutes..."
docker-compose up -d
while [ "`docker inspect -f {{.State.Health.Status}} mcscripts_mc_1`" != "healthy" ]; do     sleep 2; done;
echo "Applying configuration files..."
rsync -avr --exclude='README.md' config/ server/
docker-compose restart
echo "Done!"
# docker pull itzg/minecraft-server
# docker run -d -it -p 25565:25565 -e EULA=TRUE -e TYPE=PAPER -e USE_AIKAR_FLAGS=true -e MAX_TICK_TIME=-1 -e SPIGET_RESOURCES=48853,60088 -v /home/$USER/mc:/data --name mc itzg/minecraft-server