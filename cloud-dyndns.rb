require 'rubygems'

module CloudDyndns
  VERSION='0.0.1'
  ROOTDIR=File.expand_path(File.join(File.dirname(__FILE__)))
  LIBDIR=File.join(ROOTDIR, 'lib')
end


require File.join CloudDyndns::LIBDIR, 'config'
require File.join CloudDyndns::LIBDIR, 'updater'
