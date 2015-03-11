# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "socialization/version"

Gem::Specification.new do |s|
  s.name = "socialization-cassandra"
  s.version = Socialization::VERSION
  s.authors = ["Amrit Singh"]
  s.email = "amrit0403@gmail.com"
  s.homepage = "https://github.com/amritsingh/socialization-cassandra"
  s.summary = "Easily socialize your app with Likes and Follows"
  s.description = "Socialization allows any model to Follow and/or Like any other model. This is accomplished through a double polymorphic relationship on the Follow and Like models. But you don't need to know that since all the complexity is hidden from you."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.has_rdoc = false

  s.add_runtime_dependency "activerecord"
  s.add_runtime_dependency "cassandra-driver"

  s.add_development_dependency "logger"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "yard"
  s.add_development_dependency "minitest", "~> 4.0"
end
