%w(
  lib/*.rb
  stores/mixins/base.rb
  stores/mixins/**/*.rb
  stores/cassandra/mixins/base.rb
  stores/cassandra/mixins/**/*.rb
  stores/cassandra/base.rb
  stores/cassandra/**/*.rb
  actors/**/*.rb
  victims/**/*.rb
  helpers/**/*.rb
  config/**/*.rb
).each do |path|
  Dir["#{File.dirname(__FILE__)}/socialization/#{path}"].each { |f| require(f) }
end

ActiveRecord::Base.send :include, Socialization::ActsAsHelpers
