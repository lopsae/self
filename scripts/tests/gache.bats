

testRepo='testrepo_gache'

# Creates a repository with committed files, stashes, and some workspace
# modifications:
#
# testrepo
# ┣ firstfile  (commited, stashed)
# ┣ secondfile (commited, stashed)
# ┣ thirdfile  (commited, stashed)
# ┣ fourthfile (commited, modified)
# ┗ fifthfile  (untracked)
setup() {
	rm -rf $testRepo

	mkdir $testRepo
	cd $testRepo

	git init
	echo 'first file' > firstfile
	echo 'second file' > secondfile
	echo 'third file' > thirdfile
	echo 'fourth file' > fourthfile
	git add --all
	git commit -m 'First commit'

	echo 'first changed' > firstfile
	git stash save 'first stash'

	echo 'second changed' > secondfile
	git stash save 'second stash'

	echo 'third changed' > thirdfile
	git stash save 'third stash'

	echo 'fourth changed' > fourthfile
	echo 'fifth file' > fifthfile

	# stashes at this point:
	# 0: third stash (M thirdfile)
	# 1: second stash (M secondfile)
	# 2: first stash (M firstfile)
}


teardown() {
	cd ..
	rm -rf $testRepo
}


@test 'gache help output and invalid commands' {
	run gache
	[[ ${#output} -eq 3 ]]

	helpDocRegex='^NAME[[:space:]]+gache'
	[[ $(gache h) =~ $helpDocRegex ]] || false
	[[ $(gache help) =~ $helpDocRegex ]] || false

	run gache nothelp
	[[ $status -gt 0 ]] || false

	run gache x
	[[ $status -gt 0 ]] || false
}


@test 'gache save and apply' {
	[[ $(gache | wc -l) -eq 3 ]] || false

	gache s
	[[ $(gache | wc -l) -eq 4 ]] || false

	[[ $(cat fourthfile) == 'fourth file' ]] || false
	[[ ! -f fifthfile ]] || false

	gache a
	[[ $(gache | wc -l) -eq 4 ]] || false
	[[ $(cat fourthfile) == 'fourth changed' ]] || false
	[[ $(cat fifthfile) == 'fifth file' ]] || false

	[[ $(cat thirdfile) == 'third file' ]] || false
	gache a 1
	[[ $(gache | wc -l) -eq 4 ]] || false
	[[ $(cat thirdfile) == 'third changed' ]] || false

	[[ $(cat secondfile) == 'second file' ]] || false
	gache apply 2
	[[ $(gache | wc -l) -eq 4 ]] || false
	[[ $(cat secondfile) == 'second changed' ]] || false

	run gache a 10
	[[ $status -gt 0 ]]
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache apply 10
	[[ $status -gt 0 ]]
	[[ $(gache | wc -l) -eq 4 ]] || false

	gache s 'short save message'
	[[ $(gache | wc -l) -eq 5 ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false

	run gache
	[[ ${output[0]} =~ 'short save message' ]] || false

	gache apply
	[[ $(cat fourthfile) == 'fourth changed' ]] || false
	[[ $(cat secondfile) == 'second changed' ]] || false

	gache save 'long save' message
	[[ $(gache | wc -l) -eq 6 ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false

	run gache
	[[ ${output[0]} =~ 'long save message' ]] || false
}


@test 'gache pop and drop' {
	[[ $(gache | wc -l) -eq 3 ]] || false

	gache save fourth stash

	# stashes at this point:
	# 0: fourth stash (M fourthfile ? fifthfile)
	# 1: third stash (M thirdfile)
	# 2: second stash (M secondfile)
	# 3: first stash (M firstfile)

	# Repeating the current 4 stashes
	gache apply 3
	gache save first repeat stash
	gache apply 3
	gache save second repeat stash
	gache apply 3
	gache save third repeat stash
	gache apply 3
	gache save fourth repeat stash

	# stashes at this point:
	# 0: fourth repeat stash (M fourthfile ? fifthfile)
	# 1: third repeat stash (M thirdfile)
	# 2: second repeat stash (M secondfile)
	# 3: first repeat stash (M firstfile)
	# 4: fourth stash (M fourthfile ? fifthfile)
	# 5: third stash (M thirdfile)
	# 6: second stash (M secondfile)
	# 7: first stash (M firstfile)

	[[ $(gache | wc -l) -eq 8 ]] || false

	# First 4 stashes are popped
	# pop   > 0: fourth repeat stash (M fourthfile ? fifthfile)
	# p     > 1: third repeat stash (M thirdfile)
	# pop x > 2: second repeat stash (M secondfile)
	# p x   > 3: first repeat stash (M firstfile)
	# ...

	# p x > first
	[[ $(gache) =~ 'first repeat stash' ]] || false
	[[ $(cat firstfile) == 'first file' ]] || false
	gache p 3
	[[ ! $(gache) =~ 'first repeat stash' ]] || false
	[[ $(cat firstfile) == 'first changed' ]] || false
	[[ $(gache | wc -l) -eq 7 ]] || false

	# pop x > second
	[[ $(gache) =~ 'second repeat stash' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	gache pop 2
	[[ ! $(gache) =~ 'second repeat stash' ]] || false
	[[ $(cat secondfile) == 'second changed' ]] || false
	[[ $(gache | wc -l) -eq 6 ]] || false

	# p > fourth
	[[ $(gache) =~ 'fourth repeat stash' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false
	gache p
	[[ ! $(gache) =~ 'fourth repeat stash' ]] || false
	[[ $(cat fourthfile) == 'fourth changed' ]] || false
	[[ $(gache | wc -l) -eq 5 ]] || false

	# pop > third
	[[ $(gache) =~ 'third repeat stash' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	gache pop
	[[ ! $(gache) =~ 'third repeat stash' ]] || false
	[[ $(cat thirdfile) == 'third changed' ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	# All changes are stashed and dropped for cleanup
	gache save
	[[ $(gache | wc -l) -eq 5 ]] || false

	gache drop 0
	[[ $(gache | wc -l) -eq 4 ]] || false

	# Unmodified files
	[[ $(cat firstfile) == 'first file' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false

	# Next 4 stashes are dropped
	# drop   > 0: fourth stash (M fourthfile ? fifthfile)
	# d      > 1: third stash (M thirdfile)
	# drop x > 2: second stash (M secondfile)
	# d x    > 3: first stash (M firstfile)

	# d x > first
	[[ $(gache) =~ 'first stash' ]] || false
	[[ $(cat firstfile) == 'first file' ]] || false
	gache d 3
	[[ ! $(gache) =~ 'first stash' ]] || false
	[[ $(cat firstfile) == 'first file' ]] || false
	[[ $(gache | wc -l) -eq 3 ]] || false

	# drop x > second
	[[ $(gache) =~ 'second stash' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	gache drop 2
	[[ ! $(gache) =~ 'second stash' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	[[ $(gache | wc -l) -eq 2 ]] || false

	# drop > fourth
	[[ $(gache) =~ 'fourth stash' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false
	gache drop 0
	[[ ! $(gache) =~ 'fourth stash' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false
	[[ $(gache | wc -l) -eq 1 ]] || false

	# d > fourth
	[[ $(gache) =~ 'third stash' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	gache d 0
	[[ ! $(gache) =~ 'third stash' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	[[ $(cat firstfile) == 'first file' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false
}


@test 'invalid indexes' {
	[[ $(gache | wc -l) -eq 3 ]] || false

	# Enviroment cleanup
	gache save
	[[ $(gache | wc -l) -eq 4 ]] || false

	# Invalid indexes
	run gache apply 4
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache a 5
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache pop 4
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache p 5
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache drop 4
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache d 5
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	# Emtpy stashes
	gache drop 0
	gache d 0
	gache drop 0
	gache d 0
	[[ $(gache | wc -l) -eq 0 ]] || false

	# Unmodified files
	[[ $(cat firstfile) == 'first file' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false

	# Retry bad indexes
	run gache apply 0
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache a 1
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache pop 0
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache p 1
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache drop 0
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache d 1
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	# Unmodified files
	[[ $(cat firstfile) == 'first file' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false

	# Without index
	run gache apply
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache a
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache pop
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache p
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache drop 0
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache d
	[[ $status -gt 0 ]] || false
	[[ $(gache | wc -l) -eq 0 ]] || false

	# Unmodified files
	[[ $(cat firstfile) == 'first file' ]] || false
	[[ $(cat secondfile) == 'second file' ]] || false
	[[ $(cat thirdfile) == 'third file' ]] || false
	[[ $(cat fourthfile) == 'fourth file' ]] || false
}


@test 'invalid arguments' {
	run gache 2 extra
	[[ $status -gt 0 ]] || false

	# TODO Invalid until implemented
	run gache 2
	[[ $status -gt 0 ]] || false

	# Pop
	run gache pop 2 extra
	[[ $status -gt 0 ]] || false

	run gache pop notnumber
	[[ $status -gt 0 ]] || false

	run gache p 2 extra
	[[ $status -gt 0 ]] || false

	run gache p notnumber
	[[ $status -gt 0 ]] || false

	[[ $(gache | wc -l) -eq 3 ]] || false

	# Apply
	run gache apply 2 extra
	[[ $status -gt 0 ]] || false

	run gache apply notnumber
	[[ $status -gt 0 ]] || false

	run gache a 2 extra
	[[ $status -gt 0 ]] || false

	run gache a notnumber
	[[ $status -gt 0 ]] || false

	[[ $(gache | wc -l) -eq 3 ]] || false

	# Drop
	run gache drop 2 extra
	[[ $status -gt 0 ]] || false

	run gache drop notnumber
	[[ $status -gt 0 ]] || false

	run gache drop
	[[ $status -gt 0 ]] || false

	run gache d 2 extra
	[[ $status -gt 0 ]] || false

	run gache d notnumber
	[[ $status -gt 0 ]] || false

	run gache d
	[[ $status -gt 0 ]] || false

	[[ $(gache | wc -l) -eq 3 ]] || false
}


