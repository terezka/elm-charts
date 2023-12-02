.PHONY: serve generate build

serve:
	(/Users/tereza/github/cherry-pages/cli/dist/build/cherry-pages/cherry-pages develop)

generate:
	/Users/tereza/github/documentation-helper/dist-newstyle/build/aarch64-osx/ghc-9.2.8/documentation-helper-0.1.0.0/x/documentation-helper/build/documentation-helper/documentation-helper
	/Users/tereza/github/documentation-helper/dist-newstyle/build/aarch64-osx/ghc-9.2.8/documentation-helper-0.1.0.0/x/documentation-helper/build/documentation-helper/documentation-helper --recursive=false --input="./src/Articles" --output="./src/Articles" --has-code=false --custom-map="Ui.Article.map" --custom-imports="Ui.Article"
	elm make src/Main.elm --output=public/main.js

build:
	elm make src/Main.elm --output=public/main.js --optimize