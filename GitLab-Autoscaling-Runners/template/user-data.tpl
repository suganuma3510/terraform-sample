# Docker Machine install
if [[ `echo ${docker_machine_download_url}` == "" ]]
then
  sudo curl -O https://gitlab-docker-machine-downloads.s3.amazonaws.com/main/docker-machine-Linux-x86_64 >/tmp/docker-machine
else
  sudo curl -O ${docker_machine_download_url} >/tmp/docker-machine
fi

sudo chmod +x /tmp/docker-machine && \
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine && \
  sudo ln -s /usr/local/bin/docker-machine /usr/bin/docker-machine
docker-machine --version

# GitLab Runner install
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | sudo bash &&
sudo yum install -y gitlab-runner

# GitLab Runner register
sudo gitlab-runner register \
  --non-interactive \
  --url ${runners_gitlab_url} \
  --registration-token ${runners_token} \
  --executor docker+machine \
  --name "${runners_name}" \
  --docker-image docker:latest

sudo cat > /etc/gitlab-runner/config.toml <<- EOF

${runners_config}

EOF

sudo gitlab-runner restart
sudo gitlab-runner verify