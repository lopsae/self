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

If there are conflicted files these will be displayed with an `FX` marker:

	MF file_missing_in_home # found on backup, missing in home
	FX conflicted_file      # found on both locations, different file

If there are no important collisions just force all dotfiles into the home directory:

	./self/scripts/dotcheck -s self/dotfiles/dotcheck -F

After restarting the console the new settings should take place. Running `setback` will display setting files to be copied with a syntax similar to `dotcheck`. If there are no important conflicts deploy the setting files with:

	setback -D


Dependencies
------------

Some of the scrips in *self* depend on the [gick][gick] project.


[gick]: https://github.com/lopsae/gick

