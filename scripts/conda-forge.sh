#!/usr/bin/env bash

pushd pandas-feedstock
echo `git status`
git checkout -B RLS-"${PANDAS_VERSION}"
git pull

sed -i.bak 's/sha256: .*/sha256: '$PANDAS_SHA'/'
sed -i.bak 's/set version=.*/set version="'$PANDAS_VERSION'" %}/'
sed -i.bak 's/number: .*/number: 0/'

git add recipe/meta.yaml
git commit -m "RLS $PANDAS_VERSION"
git diff HEAD~1

popd
