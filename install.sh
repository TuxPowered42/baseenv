#!/bin/sh

rm -rf ~/.vim
cp -r vim ~/.vim

rm -rf ~/.tmux
cp -r tmux/tmux ~/.tmux
cp tmux/tmux.conf ~/.tmux.conf
