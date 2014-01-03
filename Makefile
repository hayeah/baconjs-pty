.PHONY: watch js repl build rebuild clean build_dir

js_src=src
js_out=build

build: build_dir js

rebuild: clean build

build_dir:
	mkdir -p $(js_out)

watch:
	watchy -w $(js_src) -- make js

browserify := browserify --debug -t coffeeify --extension='.coffee' --no-detect-globals

js: $(addprefix $(js_out)/,vendor.js app.js)

$(js_out)/app.js: $(js_src)/app.coffee $(shell find $(js_src) -type f -name '*.coffee')
	echo $^
	$(browserify) -o $@ $< || rm $@
	# coffee -o $(js_out) -m $<

$(js_out)/vendor.js: $(js_src)/vendor.txt
	cat $< | xargs cat | cat > $@

server:
	watchy -w server.coffee -- coffee server.coffee

clean:
	rm -r $(js_out)