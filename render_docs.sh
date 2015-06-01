#!/bin/sh

render_docs() {
    echo "# Checkout the branch for rendered docs"
    git checkout -b 'updatingdocs'

    echo "# Re-compile rendered asciidocs to html and pdf"
    make clean html pdf

    echo "# Add any new files in the rendered docs directory"
    git add ./Documents/EngagementJournal/*

    echo "# Commit to branch"
    git commit ./Documents/EngagementJournal/* -m 'updating rendered docs'

    echo "# Checkout master branch"
    git checkout master

    echo "# Merge updatingdocs to master"
    git merge updatingdocs

    echo "# Push to git repository"
    git push
}

echo "# if log directory doesn't exist then create it"
if [ ! -d ./log ] ; then
    mkdir ./log
fi

echo "# Pulling from git repo"
git pull > ./log/git.log

echo "# Checking if local copy is already up to date"
# if so then skip, otherwise render docs"
if [  "`grep -c 'Already up-to-date.' ./log/git.log`" == "0" ] ; then
  echo "# Rendering Docs"
  render_docs
else
  echo "# Skipping, nothing here to update"
  exit 0
fi
