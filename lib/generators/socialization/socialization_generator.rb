require 'rails/generators'
require 'rails/generators/migration'

class SocializationGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path(File.join('templates'), File.dirname(__FILE__))

  def create_migration_file
    copy_file "cassandra/model_follow.rb",  'app/models/follow.rb'
    copy_file "cassandra/model_like.rb",    'app/models/like.rb'
    copy_file "cassandra/model_comment.rb", 'app/models/comment.rb'
    copy_file "cassandra/model_share.rb", 'app/models/share.rb'

    migration_template 'socialization_cassandra_migrations.rake', 'lib/tasks/socialization_cassandra_migrations.rake'

  end
end
