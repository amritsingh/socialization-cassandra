require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class CassandraStoreConfigTest < Minitest::Test
  context "cassandra" do
    setup do
      Socialization.instance_eval {
        @cassandra = nil
        @cas_keyspace = nil
        @cassandra_session = nil
      }
    end

    should "return a new cassandra object when none were specified" do
      assert_instance_of Cassandra::Session, Socialization.cassandra_session
    end

    #should "always return the same Cassandra object when none were specified" do
    #  cassandra_session = Socialization.cassandra_session
    #  assert_same cassandra_session, Socialization.cassandra_session
    #end

    # should "be able to set and get a cassandra instance" do
    #   cluster = Cassandra.cluster
    #   Socialization.cassandra = cluster
    #   Socialization.keyspace = 'system'
    #   session  = cluster.connect('system')
    #   assert_same session, Socialization.cassandra_session
    # end

    #should "always return the same Redis object when it was specified" do
    #  redis = Redis.new
    #  Socialization.redis = redis
    #  assert_same redis, Socialization.redis
    #end
  end
end
