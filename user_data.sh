
#!/bin/bash
# Export variables
export last_version_ubuntu
# Update system
sudo apt update
# Install docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce -y
# Install docker_compose
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Docker pull image
docker pull texnodgo/apache2-image:$last_version_ubuntu
# Docker run
sudo docker run -d -p 80:80 texnodgo/apache2-image:$last_version_ubuntu
<< EOF
echo "$last_version_ubuntu"
EOF
