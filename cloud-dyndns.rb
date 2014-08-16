require 'rubygems'


module CloudDyndns
  ROOTDIR = File.expand_path(File.join(File.dirname(__FILE__)))
  LIBDIR  = File.join(ROOTDIR, 'lib')
end


require File.join CloudDyndns::LIBDIR, 'version'
require File.join CloudDyndns::LIBDIR, 'config'
require File.join CloudDyndns::LIBDIR, 'updater'
