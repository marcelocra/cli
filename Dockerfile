# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ENV HOME="/root"

ARG shell_rc="${HOME}/.bashrc"

# Create a reasonably decent prompt line.
RUN echo 'PS1="\$(printf \"=%.0s\" \$(seq 1 \${COLUMNS}))\n[\$(TZ=\"America/Sao_Paulo\" date \"+%F %T\")] [\w]\n# "' >> ${shell_rc}

# Update and install essentials.
RUN apt-get update
RUN apt-get install -y wget git tmux ripgrep curl unzip neovim less xz-utils

# Install git-lfs.
RUN wget https://github.com/git-lfs/git-lfs/releases/download/v3.3.0/git-lfs-linux-amd64-v3.3.0.tar.gz
RUN tar zxf git-lfs-linux-amd64-v3.3.0.tar.gz
RUN mv git-lfs-3.3.0/git-lfs /usr/bin
RUN rm -f ./git-lfs-linux-amd64-v3.3.0.tar.gz
RUN rm -rf ./git-lfs-3.3.0/

# Download my helpers.
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.tmux.conf -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/.gitconfig.personal.gitconfig -P ~
RUN wget https://raw.githubusercontent.com/marcelocra/dev/main/config-files/init_shell.sh -P ~
RUN echo 'source ~/init_shell.sh' >> ${shell_rc}

# ------------------------------------------------------------------------------
# - Dart -----------------------------------------------------------------------
# ------------------------------------------------------------------------------
RUN apt-get update
RUN apt-get install --no-install-recommends -y -q gnupg2 curl git ca-certificates apt-transport-https openssh-client 
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg 
# Fix the following 
RUN echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
RUN echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian testing main' | sudo tee /etc/apt/sources.list.d/dart_testing.list
RUN echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian unstable main' | sudo tee /etc/apt/sources.list.d/dart_unstable.list
RUN apt-get update
# 'unstable' for dev, 'testing' for beta, 'stable' for stable, remove the '-t' for latest.
RUN apt-get -t testing install -y dart
ENV PATH="$PATH:/usr/lib/dart/bin"
