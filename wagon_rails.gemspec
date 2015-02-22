# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'wagon_rails/version'
require 'date'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{WagonRails::RUBY_VERSION}"
  s.authors = ['ssaunier']
  s.date = Date.today.strftime('%Y-%m-%d')

  s.description = <<-HERE
WagonRails is a base Rails project with all the best practises and gems
taught at Le Wagon's FullStack Bootcamp. Students can jump start their
project without losing one day to set up everything.
  HERE

  s.email = 'seb@lewagon_rails'
  s.executables = ['wagon_rails']
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/lewagon/wagon_rails'
  s.license = 'MIT'
  s.name = 'wagon_rails'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.summary = "Generate a Rails app using Le Wagon's best practices (FullStack Bootcamp)"
  # s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = WagonRails::VERSION

  s.add_dependency 'bundler', '~> 1.3'
  s.add_dependency 'rails', WagonRails::RAILS_VERSION
  s.add_dependency 'colorize', '~> 0.7'

  # s.add_development_dependency 'rspec', '~> 2.0'
  # s.add_development_dependency 'capybara', '~> 2.2', '>= 2.2.0'
end
