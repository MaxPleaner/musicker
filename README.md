## Static Website Skeleton

This is a skeleton for static websites.

There are four main components:

  - the `gen.rb` file, which handles compilation
  - the `Guardfile`, which watches files for changes and re-compiles.
  - an extremely simple static server, `webrick.rb`
  - a `push_dist_to_gh_pages` script which will deploy the generated site

---

## About gen.rb (compilation step)

  - `gen.rb` is set up to convert `coffee`, `sass`, and `slim` files into their respective `js`, `css`, and `html`.
  - `gen.rb` looks for source files _anywhere in the tree except for `dist/`_
  - all `slim` files are compiled into `dist/<NAME>.html` files
  - all `sass` files are compiled into `dist/styles/<NAME>.css` files. Source files with a `.css` extension are also moved here.
  - all `coffee` files are compiled into `dist/scripts/<NAME>.js` files. Source files with a `.js` extension are also moved here.

There is custom implementation for template partials.
In a `slim` template, the `render` method can be used which takes one argument: a filename of another slim file.
Here's an example:

```slim
doctype html
html lang='en'
  head
  body
    == render "_my_partial.slim"
```

Note that the partial _must begin with an underscore_, and _files shouldn't begin with underscores unless they're partials_.

 _not every `slim` file is compiled to a corresponding `html` file_.
The `render` is run before the `slim=>html` conversion, and concatenates the `slim` files.

Its also possible to make custom helpers. Just add instance methods to the `helpers.rb` file

Script files should be referenced from slim like `script src='./scripts/my_script.js'`

Style files should be referenced from slim like `link rel='stylesheet' href='./styles/my_style.css'`

It's possible to run the compilation step with `ruby gen.rb`, though this is done automatically when using `guard`

## Webrick (static server)

The `ruby webrick.rb` command will `cd` into `dist/` and then run a static webrick server on port 8000.

`guard` will run this command automatically

## Guard (trigger builds and live-reload browser)

The app can be started with `guard`. This will read instructions from the `Guardfile`.

Whenever `guard` is run, an initial compilation is run and the server starts.

When the `Gemfile` changes, the server stops, `bundle` is automatically run, and the server starts up again

When a file in the `dist/` folder changes, the browser will live-reload (make sure to install the livereload chrome extension to use this feature).

When any other source file changes, the compilation step will be triggered.


## Deploying to gh-pages

1. Clone this repo, customize it however, and generate a site into `dist/`
2. Run `push_dist_to_gh_pages`, which will push the `dist/` folder to the `gh-pages` branch on github.
3. Visit the static site at `http://<my_github_username>.github.io/<my_repo_name>`
