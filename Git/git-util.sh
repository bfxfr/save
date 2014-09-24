#!/bin/bash
usage()
{
cat << EOF
usage: $0 options

This script allow to help when rebasing branches

OPTIONS:
      -s Show merged branches in branch (-b) without parent (-p)
      -g Get merged branches as an array in branch (-b) without parent (-p)
      -r ARRAY Rebase branches in array from branch (-p)
      -m ARRAY Merge branches in branch (-b)
      -b BRANCH working branch
      -p BRANCH parent branch

Sample usage :
Show merged branches in recette
	$0 -s -b recette -p master
Rebase branches merged 
	branches=\`$0 -g -b recette -p master\`
	$0 -r "\$branches" -p master
Merge branches
	git branch -f recette master
	git checkout recette
	$0 -m "\$branches" -b recette
EOF
}
BRANCH=""
PARENT=""
OP=""
OP_SHOW="SHOW"
OP_GET="GET"
OP_REBASE="REBASE"
OP_MERGE="MERGE"
ARRAY=()
while getopts "sgr:m:b:p:" opt; do
  case $opt in
    s)
	OP="$OP_SHOW"
      ;;
    g)
	OP="$OP_GET"
      ;;
    r)
        ARRAY=($OPTARG)
	OP="$OP_REBASE"
      ;;
    m)
        ARRAY=($OPTARG)
	OP="$OP_MERGE"
      ;;
    b)
        BRANCH="$OPTARG"
      ;;
    p)
	echo "$OPTARG"
        PARENT="$OPTARG"
      ;;
    \?)
        usage
        exit
      ;;
  esac
done

function getMergedBranches(){
	branch=$1;
	parent=$2
	echo `git branch -r --merged $branch | grep -v "$parent" | grep -v "$branch" | awk -F "/" '{print $2}'`
}
if [[ "$OP" == "$OP_SHOW" ]]; then
        branches=($(getMergedBranches $BRANCH $PARENT))
	for branch in "${branches[@]}"; do
		echo $branch
	done
	exit
elif  [[ "$OP" == "$OP_GET" ]]; then
        branches=($(getMergedBranches $BRANCH $PARENT))
	echo "${branches[@]}"
	exit
elif  [[ "$OP" == "$OP_REBASE" ]]; then
	for branch in "${ARRAY[@]}"; do
		git checkout $branch
		echo "------------ REBASE $branch --------------------"
		git rebase "$PARENT"
		git push -f origin $branch
	done
	exit
elif  [[ "$OP" == "$OP_MERGE" ]]; then
	git checkout $BRANCH
	for branch in "${ARRAY[@]}"; do
		echo "------------ MERGE $branch --------------------"
		git merge "$branch"
	done
	exit
else
	usage
	exit
fi
