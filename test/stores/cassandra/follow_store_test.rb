require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'
# require './../../test_helper'

class CassandraFollowStoreTest < Minitest::Test
  include Assertions
  context "CassandraStores::Follow" do
    setup do
      @klass = Socialization::CassandraStores::Follow
      @base = Socialization::CassandraStores::Base
    end

    context "method aliases" do
      should "be set properly and made public" do
        # TODO: Can't figure out how to test method aliases properly. The following doesn't work:
        # assert @klass.method(:follow!) == @base.method(:relation!)
        assert_method_public @klass, :follow!
        assert_method_public @klass, :unfollow!
        assert_method_public @klass, :follows?
        assert_method_public @klass, :followers_relation
        assert_method_public @klass, :followers
        assert_method_public @klass, :followables_relation
        assert_method_public @klass, :followables
        assert_method_public @klass, :remove_followers
        assert_method_public @klass, :remove_followables
      end
    end
  end
end
