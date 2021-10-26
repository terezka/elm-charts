.PHONY: serve generate build

serve:
	(/Users/terezka/github/cherry-pages/cli/dist/build/cherry-pages/cherry-pages develop)

generate:
	/Users/terezka/github/documentation-helper/dist/build/documentation-helper/documentation-helper
	/Users/terezka/github/documentation-helper/dist/build/documentation-helper/documentation-helper --recursive=false --input="./src/Articles" --output="./src/Articles" --has-code=false --custom-map="Ui.Article.map" --custom-imports="Ui.Article"
	elm make src/Main.elm --output=public/main.js

build:
	elm make src/Main.elm --output=public/main.js --optimize