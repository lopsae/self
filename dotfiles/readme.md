dotfiles
========

Backups of settings files that live in the `home` folder.

The script dotcheck can be used to deploy the dotfiles initialy, and later
to check that the backup is still current.

For the initial deploy of dotfiles:

    dotcheck -Fs path-to-self/dotcheck/self_dotcheck

To check the current status of dotfiles:

    dotcheck

To update the backup copy with the current dotfiles in home:

    dotcheck -u
