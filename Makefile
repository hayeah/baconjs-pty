.PHONY: watch js repl

js_src=src
js_out=build

watch:
	watchy -w $(js_src) -- make js

js: $(js_out) $(addprefix $(js_out)/,vendor.js app.js)

$(js_out):
	mkdir -p $(js_out)

$(js_out)/app.js: $(js_src)/app.coffee
	coffee -o $(js_out) -m $<

$(js_out)/vendor.js: $(js_src)/vendor.txt
	cat $< | xargs cat | cat > $@

server:
	watchy -w server.coffee -- coffee server.coffee