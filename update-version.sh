#!/bin/bash

git pull

date > version

git add version

git commit -m "new date"

git push

echo "done :)"
