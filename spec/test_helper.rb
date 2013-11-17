require 'rubygems'
require 'fileutils'
require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/reporters'
require 'minitest/matchers'
require 'minitest/spec/expect'

require File.join(File.dirname(__FILE__), '..', 'cloud-dyndns')

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
