self
====

Settings and tools for self use.


Quick Setup
-----------

The usual clone folder for self is in your home directory, in `~/self`:

	cd
	git clone git@github.com:lopsae/self.git self

Run `dotcheck`. This first time it is just to assert what collitions of dotfiles there will be. Usualy only `.bash_profile` exists beforehand:

	./self/scripts/dotcheck -s self/dotfiles/dotcheck

If there are no important collisions just force all dotfiles into the home directory:

	./self/scripts/dotcheck -s self/dotfiles/dotcheck -F


Dependencies
------------

Some of the scrips in *self* depend on the [gick][gick] project.


[gick]: https://github.com/lopsae/gick

