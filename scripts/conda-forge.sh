#!/usr/bin/env bash
set -e


if [[ $1 != v* ]];
then
    echo "Invalid tag $1"
    echo "Must be formatted like vX.X.X"
	exit 1
fi

PANDAS_VERSION="${1:1}"
PANDAS_SHA=$(openssl dgst -sha256 pandas/dist/pandas-${PANDAS_VERSION}.tar.gz | cut -d ' ' -f 2)

pushd pandas-feedstock
git checkout master
git pull upstream

echo `git status`
git checkout -B RLS-"${PANDAS_VERSION}"

sed -i 's/sha256: .*/sha256: '$PANDAS_SHA'/' recipe/meta.yaml
sed -i 's/set version = .*/set version = "'$PANDAS_VERSION'" %}/' recipe/meta.yaml
sed -i 's/number: .*/number: 0/' recipe/meta.yaml

git add recipe/meta.yaml
git commit -m "RLS $PANDAS_VERSION"
git diff HEAD~1 | cat

popd
