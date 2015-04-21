

testRepo="testrepo_gache"

setup() {
	rm -rf $testRepo

	mkdir $testRepo
	cd $testRepo

	git init
	echo "first file" > firstfile
	echo "second file" > secondfile
	echo "third file" > thirdfile
	git add --all
	git commit -m "First commit"

	echo "first changed" > firstfile
	git stash save "first stash"

	echo "second changed" > secondfile
	git stash save "second stash"

	echo "third changed" > thirdfile
	echo "fourth file" > fourthfile
}

teardown() {
	cd ..
	rm -rf $testRepo
}

@test "gache prints help" {
	[[ $(gache h) =~ ^NAME ]]
	[[ $(gache help) =~ ^NAME ]]

	# run gache help

	# [[ "$status" -ne 1 ]]
	# [[ "$output" = 'Invalid arguments' ]]

}

# @test "gache save and pop" {
# 	[[ $(gache | lc -l) -eq 2 ]]

# 	gache s
# 	result="$(echo 2+2 | bc)"
# 	[ "$result" -eq 4 ]

# }

# @test "addition using dc" {
# 	result="$(echo 2 2+p | dc)"
# 	[ "$result" -eq 4 ]
# }