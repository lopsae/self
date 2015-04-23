

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

	shortSaveMessage='save message short'
	gache s $shortSaveMessage
	[[ $(gache | wc -l) -eq 5 ]] || false
	[[ $(cat thirdfile) == "third file" ]] || false
	[[ $(cat fourthfile) == "fourth file" ]] || false

	run gache
	[[ ${output[0]} =~ $shortSaveMessage ]] || false

	gache apply
	[[ $(cat fourthfile) == "fourth changed" ]] || false
	[[ $(cat secondfile) == "second changed" ]] || false

	longSaveMessage='save message long'
	gache save $longSaveMessage
	[[ $(gache | wc -l) -eq 6 ]] || false
	[[ $(cat thirdfile) == "third file" ]] || false
	[[ $(cat fourthfile) == "fourth file" ]] || false

	run gache
	[[ ${output[0]} =~ $longSaveMessage ]] || false
}
