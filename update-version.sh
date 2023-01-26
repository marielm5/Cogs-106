#!/bin/bash

git checkout main
git fetch --all --prune
git rebase
git -C repo/ checkout -b bugfix

echo "Today is $date"

git -C repo/ commit -a -m "Fixed bug"
git push
