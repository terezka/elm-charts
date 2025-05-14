rm -r ../elm-charts-alpha/src
cp -r ./src ../elm-charts-alpha/src

rm -r ../elm-charts-alpha/docs
cp -r ./docs ../elm-charts-alpha/docs

rm ../elm-charts-alpha/elm.json
cp ./elm.json ../elm-charts-alpha/elm.json

vim ../elm-charts-alpha/elm.json

echo -e "# Elm Charts Alpha\n\nThis is the alpha version of elm-charts. Use at own risk.\n" > ../elm-charts-alpha/README.md
echo -e "-------------\n" >> ../elm-charts-alpha/README.md
cat ./README.md >> ../elm-charts-alpha/README.md