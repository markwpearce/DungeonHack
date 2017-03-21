#!/bin/bash
OLD_VERSION=$(head -n 1 version.txt)
NEW_VERSION=`awk -F. '/[0-9]+\./{$NF++;print}' OFS=. <<< echo version.txt `;

declare -a files=('./Project.xml' './source/dungeonhack/states/MenuState.hx' './version.txt');


echo "Updating $OLD_VERSION to $NEW_VERSION in ${files[@]} ..."

sed -i '' -e "s/$OLD_VERSION/$NEW_VERSION/g" ./Project.xml
sed -i '' -e "s/$OLD_VERSION/$NEW_VERSION/g" ./source/dungeonhack/states/MenuState.hx
sed -i '' -e "s/$OLD_VERSION/$NEW_VERSION/g" ./version.txt

