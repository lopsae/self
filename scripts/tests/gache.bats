

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
	# rm -rf $testRepo
}

@test "gache help output and invalid commands" {
	run gache
	[[ ${#output} -eq 3 ]]

	[[ $(gache h) =~ ^NAME ]]
	[[ $(gache help) =~ ^NAME ]]

	run gache nothelp
	[[ $status -ne 0 ]]

	run gache x
	[[ $status -ne 0 ]]
}

@test "gache save and apply" {
	[[ $(gache | wc -l) -eq 3 ]] || false

	gache s
	[[ $(gache | wc -l) -eq 4 ]] || false
}
