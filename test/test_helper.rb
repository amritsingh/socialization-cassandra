$MOCK_REDIS = true

require 'rubygems'
require 'active_record'
require 'shoulda'
# require 'test/unit'
require 'logger'
require 'mocha' # mocha always needs to be loaded last! http://stackoverflow.com/questions/3118866/mocha-mock-carries-to-another-test/4375296#4375296
# require 'pry'
require 'minitest/autorun'
require 'cassandra'

$:.push File.expand_path("../lib", __FILE__)
require "socialization"

module Assertions
  def assert_true(object, message="")
    assert_equal(true, object, message)
  end

  def assert_false(object, message="")
    assert_equal(false, object, message)
  end

  def build_message(head, template=nil, *arguments) #:nodoc:
    template &&= template.chomp
    template.gsub(/\G((?:[^\\]|\\.)*?)(\\)?\?/) { $1 + ($2 ? "?" : mu_pp(arguments.shift))  }
  end

  def assert_array_similarity(expected, actual, message=nil)
    full_message = build_message(message, "<?> expected but was\n<?>.\n", expected, actual)
    assert((expected.size ==  actual.size) && (expected - actual == []), full_message)
    # assert_block(full_message) { (expected.size ==  actual.size) && (expected - actual == []) }
  end

  def assert_empty(obj, msg = nil)
    msg = "Expected #{obj.inspect} to be empty" unless msg
    assert_respond_to obj, :empty?
    assert obj.empty?, msg
  end

  def assert_method_public(obj, method, msg = nil)
    msg = "Expected method #{obj}.#{method} to be public."
    method = if RUBY_VERSION.match(/^1\.8/)
      method.to_s
    else
      method.to_s.to_sym
    end

    assert obj.public_methods.include?(method), msg
  end
end

class TestCase < Minitest::Test
  def setup
    use_cassandra_store
  end

  def teardown
    session = Socialization.cassandra_session
    # ['likes', 'likers', 'liker_counter', 'followings', 'followers', 'following_counter', 'follower_counter', 'comments', 'comment_counter', 'shares', 'share_counter'].each {|t| session.execute("TRUNCATE #{t}")}
    ['likes', 'likers', 'liker_counter', 'followings', 'followers', 'following_counter', 'follower_counter'].each {|t| session.execute("TRUNCATE #{t}")}
  end
end

def use_cassandra_store
  Socialization.follow_model = Socialization::CassandraStores::Follow
  Socialization.comment_model = Socialization::CassandraStores::Comment
  Socialization.share_model = Socialization::CassandraStores::Share
  Socialization.like_model = Socialization::CassandraStores::Like
  setup_model_shortcuts
end

def setup_model_shortcuts
  $Follow = Socialization.follow_model
  $Comment = Socialization.comment_model
  $Share = Socialization.share_model
  $Like = Socialization.like_model
end

ActiveRecord::Base.configurations = {'sqlite3' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection(:sqlite3)

ActiveRecord::Base.logger = Logger.new(STDERR)
ActiveRecord::Base.logger.level = Logger::WARN

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end

  create_table :celebrities do |t|
    t.string :name
  end

  create_table :movies do |t|
    t.string :name
  end

  create_table :follows do |t|
    t.string  :follower_type
    t.integer :follower_id
    t.string  :followable_type
    t.integer :followable_id
    t.datetime :created_at
  end

  create_table :likes do |t|
    t.string  :liker_type
    t.integer :liker_id
    t.string  :likeable_type
    t.integer :likeable_id
    t.datetime :created_at
  end

  create_table :comments do |t|
    t.string  :commenter_type
    t.integer :commenter_id
    t.string  :commentable_type
    t.integer :commentable_id
    t.datetime :created_at
  end

  create_table :shares do |t|
    t.string  :sharer_type
    t.integer :sharer_id
    t.string  :shareable_type
    t.integer :shareable_id
    t.datetime :created_at
  end

  create_table :im_a_followers do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_followables do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_likers do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_likeables do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_commenters do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_commentables do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_commenter_and_commentables do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_sharers do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_shareables do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :im_a_sharer_and_shareables do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :vanillas do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end
end

class Celebrity < ActiveRecord::Base
  acts_as_followable
end

class User < ActiveRecord::Base
  acts_as_follower
  acts_as_followable
  acts_as_liker
  acts_as_likeable
  acts_as_commenter
  acts_as_sharer
end

class Movie < ActiveRecord::Base
  acts_as_likeable
  acts_as_commentable
  acts_as_shareable
end

class ImAFollower < ActiveRecord::Base
  acts_as_follower
end
class ImAFollowerChild < ImAFollower; end

class ImAFollowable < ActiveRecord::Base
  acts_as_followable
end
class ImAFollowableChild < ImAFollowable; end

class ImALiker < ActiveRecord::Base
  acts_as_liker
end
class ImALikerChild < ImALiker; end

class ImALikeable < ActiveRecord::Base
  acts_as_likeable
end
class ImALikeableChild < ImALikeable; end

class ImACommenter < ActiveRecord::Base
  acts_as_commenter
end
class ImACommenterChild < ImACommenter; end

class ImACommentable < ActiveRecord::Base
  acts_as_commentable
end
class ImACommentableChild < ImACommentable; end

class ImACommenterAndCommentable < ActiveRecord::Base
  acts_as_commenter
  acts_as_commentable
end

class ImASharer < ActiveRecord::Base
  acts_as_sharer
end
class ImASharerChild < ImASharer; end

class ImAShareable < ActiveRecord::Base
  acts_as_shareable
end
class ImAShareableChild < ImAShareable; end

class ImASharerAndShareable < ActiveRecord::Base
  acts_as_sharer
  acts_as_shareable
end

class Vanilla < ActiveRecord::Base
end
