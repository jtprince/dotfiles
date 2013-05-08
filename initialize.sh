#!/bin/bash

# ensures that we have a recent version of ruby installed
# and kicks things over to initialize.rb

set -o pipefail

pushd $HOME

if [ -f /etc/debian_version ] ; then
    RBENV_PREREQS="git vim-gtk git curl xclip zlib1g-dev build-essential libssl-dev libreadline-dev"
    echo "debian based system"
    echo "going to install prereqs: $RBENV_PREREQS"
    sudo apt-get install $RBENV_PREREQS
fi

# rbenv
if [ ! -d ~/.rbenv ]; then
    git clone git://github.com/sstephenson/rbenv.git .rbenv
fi
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# ruby-build
if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
    mkdir -p ~/.rbenv/plugins
    cd ~/.rbenv/plugins
    git clone git://github.com/sstephenson/ruby-build.git
    cd
fi
export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# what is the latest stable ruby build?
latest_ruby=`rbenv install --list | grep 'p[0-9]\+' | tail -1`

# install it if we don't have it
our_ruby=`rbenv versions | grep -o '[0-9\.]\+-p[0-9]\+' | tail -1`

if [ "$our_ruby" == "$latest_ruby" ]; then
    rbenv install "$latest_ruby"
fi

popd


if [ -f manage.rb ]; then
    ./manage.rb install
fi
