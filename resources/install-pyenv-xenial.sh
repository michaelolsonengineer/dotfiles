#!/bin/bash

set -xe

rm -rf ~/.local/lib/python2.7/
rm -rf ~/.local/lib/python3.5/
rm -f ~/.python-version

sudo rm -f /usr/bin/pip3 /usr/local/bin/pip3

sudo apt -y purge python-pip python-virtualenv 

sudo apt -y install --reinstall zlib1g=1:1.2.8.dfsg-2ubuntu4.3 && \
sudo apt -y install --reinstall zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.3 && \
sudo apt -y install --reinstall build-essential git libbz2-dev libffi-dev liblzma-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libssl-dev llvm make tk-dev xz-utils zlib1g-dev && \
sudo apt -y install --reinstall python python-pip python-dev python-openssl python3-dev python3-openssl python3-pip

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
python get-pip.py --force-reinstall

sudo rm -rf ~/.cache/pip

[ -e ~/.pyenv ] && rm -rf ~/.pyenv 2>/dev/null 
curl -f https://pyenv.run | bash

if ! grep pyenv ~/.bashrc &>/dev/null; then
  echo 'export PATH="$HOME/.pyenv/shims:$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
  echo 'eval "$(pyenv init -)"' >> ~/.bashrc
  eval 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
fi


cat <<EOT > requirements.txt
devpi-client
setuptools_scm
tox
slash
wheel
EOT

pyenv_versions=('3.6.9' '3.7.4' '3.8.1')
for ver in "${pyenv_versions[@]}"; do
    pyenv install $ver && pyenv local $ver
    pip -v install --upgrade pip && \
    pip -v install -r ./requirements.txt && \
    pyenv local --unset
done

rm requirements.txt
