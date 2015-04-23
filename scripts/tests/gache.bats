

testRepo="testrepo_gache"

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
	echo "first file" > firstfile
	echo "second file" > secondfile
	echo "third file" > thirdfile
	echo "fourth file" > fourthfile
	git add --all
	git commit -m "First commit"

	echo "first changed" > firstfile
	git stash save "first stash"

	echo "second changed" > secondfile
	git stash save "second stash"

	echo "third changed" > thirdfile
	git stash save "third stash"

	echo "fourth changed" > fourthfile
	echo "fifth file" > fifthfile
}


teardown() {
	cd ..
	rm -rf $testRepo
}


@test "gache help output and invalid commands" {
	run gache
	[[ ${#output} -eq 3 ]]

	helpDocRegex='^NAME[[:space:]]+gache'

	[[ $(gache h) =~ $helpDocRegex ]] || false
	[[ $(gache help) =~ $helpDocRegex ]] || false

	run gache nothelp
	[[ $status -ne 0 ]] || false

	run gache x
	[[ $status -ne 0 ]] || false
}


@test "gache save and apply" {
	[[ $(gache | wc -l) -eq 3 ]] || false

	gache s
	[[ $(gache | wc -l) -eq 4 ]] || false

	[[ $(cat fourthfile) == "fourth file" ]] || false
	[[ ! -f fifthfile ]] || false

	gache a
	[[ $(gache | wc -l) -eq 4 ]] || false
	[[ $(cat fourthfile) == "fourth changed" ]] || false
	[[ $(cat fifthfile) == "fifth file" ]] || false

	[[ $(cat thirdfile) == "third file" ]] || false
	gache a 1
	[[ $(gache | wc -l) -eq 4 ]] || false
	[[ $(cat thirdfile) == "third changed" ]] || false

	[[ $(cat secondfile) == "second file" ]] || false
	gache apply 2
	[[ $(gache | wc -l) -eq 4 ]] || false
	[[ $(cat secondfile) == "second changed" ]] || false

	run gache a 10
	[[ $status -ne 0 ]]
	[[ $(gache | wc -l) -eq 4 ]] || false

	run gache apply 10
	[[ $status -ne 0 ]]
	[[ $(gache | wc -l) -eq 4 ]] || false

	gache s "short save message"
	[[ $(gache | wc -l) -eq 5 ]] || false
	[[ $(cat thirdfile) == "third file" ]] || false
	[[ $(cat fourthfile) == "fourth file" ]] || false

	run gache
	[[ ${output[0]} =~ "short save message" ]] || false

	gache apply
	[[ $(cat fourthfile) == "fourth changed" ]] || false
	[[ $(cat secondfile) == "second changed" ]] || false

	gache save "long save" message
	[[ $(gache | wc -l) -eq 6 ]] || false
	[[ $(cat thirdfile) == "third file" ]] || false
	[[ $(cat fourthfile) == "fourth file" ]] || false

	run gache
	[[ ${output[0]} =~ "long save message" ]] || false
}


@test "gache pop and drop" {
	[[ $(gache | wc -l) -eq 3 ]] || false

	# Repeating the original 3 stashes
	stashToDeleteMessage='stash to delete'
	gache save $stashToDeleteMessage
	gache apply 3
	gache save first stash repeat
	gache apply 3
	gache save second stash repeat
	gache apply 3
	gache save third stash repeat

	[[ $(gache | wc -l) -eq 7 ]] || false

	[[ $(gache) =~ "stash to delete" ]] || false
	gache d 3
	[[ ! $(gache) =~ "stash to delete" ]] || false
	[[ $(gache | wc -l) -eq 6 ]] || false

	[[ $(gache) =~ "first stash repeat" ]] || false
	gache drop 2
	[[ ! $(gache) =~ "first stash repeat" ]] || false
	[[ $(gache | wc -l) -eq 5 ]] || false

	[[ $(gache) =~ "second stash repeat" ]] || false
	[[ $(cat secondfile) == "second file" ]] || false
	gache p 1
	[[ ! $(gache) =~ "second stash repeat" ]] || false
	[[ $(cat secondfile) == "second changed" ]] || false
	[[ $(gache | wc -l) -eq 4 ]] || false

	[[ $(gache) =~ "third stash repeat" ]] || false
	[[ $(cat thirdfile) == "third file" ]] || false
	gache pop
	[[ ! $(gache) =~ "third stash repeat" ]] || false
	[[ $(cat thirdfile) == "third changed" ]] || false
	[[ $(gache | wc -l) -eq 3 ]] || false

	[[ $(cat firstfile) == "first file" ]] || false
	gache 2
	[[ $(cat firstfile) == "first changed" ]] || false
	[[ $(gache | wc -l) -eq 2 ]] || false


	run gache pop 5
	[[ $status -ne 0 ]] || false
	[[ $(gache | wc -l) -eq 2 ]] || false

	run gache drop 5
	[[ $status -ne 0 ]] || false
	[[ $(gache | wc -l) -eq 2 ]] || false

	gache drop
	gache drop

	[[ $(gache | wc -l) -eq 0 ]] || false

	run gache drop
	[[ $status -ne 0 ]] || false
	run gache pop
	[[ $status -ne 0 ]] || false
}


@test "invalid arguments" {
	run gache 2 extra
	[[ $status -ne 0 ]] || false

	# Pop
	run gache pop 2 extra
	[[ $status -ne 0 ]] || false

	run gache pop something
	[[ $status -ne 0 ]] || false

	run gache p 2 extra
	[[ $status -ne 0 ]] || false

	run gache p something
	[[ $status -ne 0 ]] || false

	# Apply
	run gache apply 2 extra
	[[ $status -ne 0 ]] || false

	run gache apply something
	[[ $status -ne 0 ]] || false

	run gache a 2 extra
	[[ $status -ne 0 ]] || false

	run gache a something
	[[ $status -ne 0 ]] || false

	# Drop
	run gache drop 2 extra
	[[ $status -ne 0 ]] || false

	run gache drop something
	[[ $status -ne 0 ]] || false

	run gache d 2 extra
	[[ $status -ne 0 ]] || false

	run gache d something
	[[ $status -ne 0 ]] || false
}


