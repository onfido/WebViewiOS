#!/usr/bin/env ruby   

require 'dotenv'
Dotenv.load('.env')

`bundle exec dotenv-ios --source #{ENV["API_KEY"]}`