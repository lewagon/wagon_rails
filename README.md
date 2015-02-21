# Wagon Rails

Wagon Rails is the base Rails application used by [Le Wagon](http://www.lewagon.org/en)'s
students during the 9-week FullStack bootcamp.

## Installation

First install the wagon_rails gem:

    gem install wagon_rails

Then run:

    wagon_rails YOUR_PROJECT_NAME --heroku

This will create a Rails app in `YOUR_PROJECT_NAME` using the latest version of Rails,
create a GitHub repository and an application on Heroku.

If you want, you can omit the `--heroku` flag so that the gem does not create an Heroku app.
You can also skip the github repository creation with the following:

    wagon_rails YOUR_PROJECT_NAME --skip-github

## Dependencies

This gem suppose that you have Ruby & Postgresql on your computer. Check out
[lewagon/setup](https://github.com/lewagon/setup)

For the GitHub repo creation, it supposes you have the [hub](https://github.com/github/hub) gem
installed. You can get it with

    gem install hub

## Gemfile

To see the latest and greatest gems, look at WagonRails'
[Gemfile](templates/Gemfile.erb), which will be appended to the default
generated projectname/Gemfile.

It includes application gems like:

* [High Voltage](https://github.com/thoughtbot/high_voltage) for static pages
* [jQuery Rails](https://github.com/rails/jquery-rails) for jQuery
* [Postgres](https://github.com/ged/ruby-pg) for access to the Postgres database
* [Rack Timeout](https://github.com/kch/rack-timeout) to abort requests that are
  taking too long
* [Simple Form](https://github.com/plataformatec/simple_form) for form markup
  and style

And development gems like:

* [Pry Rails](https://github.com/rweng/pry-rails) for interactively exploring
  objects
* [Pry ByeBug](https://github.com/deivid-rodriguez/pry-byebug) for interactively
  debugging behavior
* [Spring](https://github.com/rails/spring) for fast Rails actions via
  pre-loading

## Other goodies

WagonRails also comes with:

* The `./bin/deploy` convention for deploying to Heroku
* Rails' flashes set up and in application layout
* `Rack::Deflater` to [compress responses with Gzip][compress]
* A [low database connection pool limit][pool]

## Credits

WagonRails is a fork of [thoughtbot/suspenders](https://github.com/thoughtbot/suspenders),
which is maintained and funded by [thoughtbot, inc](http://thoughtbot.com/community).

Thank you for creating this gem in the first place!
