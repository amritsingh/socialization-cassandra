require File.expand_path(File.dirname(__FILE__))+'/../../test_helper'

class CassandraBaseStoreTest < TestCase
  include Assertions
  # Testing through CassandraStores::Follow for easy testing
  context "CassandraStores::Base through CassandraStores::Follow" do
    setup do
      use_cassandra_store
      @klass = Socialization::CassandraStores::Follow
      @klass.touch nil
      @klass.after_follow nil
      @klass.after_unfollow nil
      @follower1 = ImAFollower.create
      @follower2 = ImAFollower.create
      @followable1 = ImAFollowable.create
      @followable2 = ImAFollowable.create
    end

    context "Stores" do
      should "inherit Socialization::CassandraStores::Follow" do
        assert_equal Socialization::CassandraStores::Follow, Socialization.follow_model
      end
    end

    context "#follow!" do
      should "create follow records" do
        @klass.follow!(@follower1, @followable1)
        row = Socialization.cassandra_session.execute("SELECT actor_type, actor_id FROM #{@klass.forward_table_name} where victim_type='#{@followable1.class}' AND victim_id=#{@followable1.id} ALLOW FILTERING").rows.to_a.first
        assert_array_similarity ["#{@follower1.class}:#{@follower1.id}"], ["#{row['actor_type']}:#{row['actor_id']}"]
        row = Socialization.cassandra_session.execute("SELECT victim_type, victim_id FROM #{@klass.backward_table_name} where actor_type='#{@follower1.class}' AND actor_id=#{@follower1.id} ALLOW FILTERING").rows.to_a.last
        assert_array_similarity ["#{@followable1.class}:#{@followable1.id}"], ["#{row['victim_type']}:#{row['victim_id']}"]

        @klass.follow!(@follower2, @followable1)
        rows = Socialization.cassandra_session.execute("SELECT actor_type, actor_id FROM #{@klass.forward_table_name} where victim_type='#{@followable1.class}' AND victim_id=#{@followable1.id} ALLOW FILTERING").rows
        assert_array_similarity ["#{@follower1.class}:#{@follower1.id}", "#{@follower2.class}:#{@follower2.id}"], (rows.collect {|i| "#{i['actor_type']}:#{i['actor_id']}"})

        row = Socialization.cassandra_session.execute("SELECT victim_type, victim_id FROM #{@klass.backward_table_name} where actor_type='#{@follower1.class}' AND actor_id=#{@follower1.id} ALLOW FILTERING").rows.to_a.last
        assert_array_similarity ["#{@followable1.class}:#{@followable1.id}"], ["#{row['victim_type']}:#{row['victim_id']}"]
        row = Socialization.cassandra_session.execute("SELECT victim_type, victim_id FROM #{@klass.backward_table_name} where actor_type='#{@follower2.class}' AND actor_id=#{@follower2.id} ALLOW FILTERING").rows.to_a.first
        assert_array_similarity ["#{@followable1.class}:#{@followable1.id}"], ["#{row['victim_type']}:#{row['victim_id']}"]
      end

      should "touch follower when instructed" do
        @klass.touch :follower
        assert_send([@follower1, :touch])
        assert_send([@followable1, :touch])
        @klass.follow!(@follower1, @followable1)
      end

      should "touch followable when instructed" do
        @klass.touch :followable
        !assert_send([@follower1, :touch])
        assert_send([@followable1, :touch])
        @klass.follow!(@follower1, @followable1)
      end

      should "touch all when instructed" do
        @klass.touch :all
        assert_send([@follower1, :touch])
        assert_send([@followable1, :touch])
        @klass.follow!(@follower1, @followable1)
      end

      # should "call after follow hook" do
      #   @klass.after_follow :after_follow
      #   assert_send([@klass, :after_follow])
      #   @klass.follow!(@follower1, @followable1)
      # end

      # should "call after unfollow hook" do
      #   @klass.after_follow :after_unfollow
      #   assert_send([@klass, :after_unfollow])
      #   @klass.follow!(@follower1, @followable1)
      # end
    end

    context "#unfollow!" do
      setup do
        @klass.follow!(@follower1, @followable1)
      end

      should "remove follow records" do
        @klass.unfollow!(@follower1, @followable1)
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.backward_table_name} where actor_type='#{@follower1.class}' AND actor_id=#{@follower1.id} ALLOW FILTERING").rows.to_a
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.forward_table_name} where victim_type='#{@followable1.class}' AND victim_id=#{@followable1.id} ALLOW FILTERING").rows.to_a
      end
    end

    context "#follows?" do
      should "return true when follow exists" do
        @klass.follow!(@follower1, @followable1)
        assert_true @klass.follows?(@follower1, @followable1)
      end

      should "return false when follow doesn't exist" do
        assert_false @klass.follows?(@follower1, @followable1)
      end
    end

    context "#followers" do
      should "return an array of followers" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable1)
        follower2.follow!(@followable1)
        assert_array_similarity [follower1, follower2], @klass.followers(@followable1, follower1.class)
      end

      should "return an array of follower ids when plucking" do
        follower1 = ImAFollower.create
        follower2 = ImAFollower.create
        follower1.follow!(@followable1)
        follower2.follow!(@followable1)
        assert_array_similarity [follower1.id, follower2.id], @klass.followers(@followable1, follower1.class, :pluck => :id)
      end
    end

    context "#followables" do
      should "return an array of followables" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower1.follow!(followable1)
        @follower1.follow!(followable2)

        assert_array_similarity [followable1, followable2], @klass.followables(@follower1, followable1.class)
      end

      should "return an array of followables ids when plucking" do
        followable1 = ImAFollowable.create
        followable2 = ImAFollowable.create
        @follower1.follow!(followable1)
        @follower1.follow!(followable2)
        assert_array_similarity [followable1.id, followable2.id], @klass.followables(@follower1, followable1.class, :pluck => :id)
      end
    end

    context "#remove_followers" do
      should "delete all followers relationships for a followable" do
        @follower1.follow!(@followable1)
        @follower2.follow!(@followable1)
        assert_equal 2, @followable1.followers(@follower1.class).count

        @klass.remove_followers(@followable1)
        assert_equal 0, @followable1.followers(@follower1.class).count
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.forward_table_name} where victim_type='#{@followable1.class}' AND victim_id=#{@followable1.id} ALLOW FILTERING").rows.to_a
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.backward_table_name} where actor_type='#{@follower1.class}' AND actor_id=#{@follower1.id} ALLOW FILTERING").rows.to_a
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.backward_table_name} where actor_type='#{@follower2.class}' AND actor_id=#{@follower2.id} ALLOW FILTERING").rows.to_a
      end
    end

    context "#remove_followables" do
      should "delete all followables relationships for a follower" do
        @follower1.follow!(@followable1)
        @follower1.follow!(@followable2)
        assert_equal 2, @follower1.followables(@followable1.class).count

        @klass.remove_followables(@follower1)
        assert_equal 0, @follower1.followables(@followable1.class).count
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.forward_table_name} where victim_type='#{@followable1.class}' AND victim_id=#{@followable1.id} ALLOW FILTERING").rows.to_a
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.backward_table_name} where actor_type='#{@follower1.class}' AND actor_id=#{@follower1.id} ALLOW FILTERING").rows.to_a
        assert_empty Socialization.cassandra_session.execute("SELECT * FROM #{@klass.backward_table_name} where actor_type='#{@follower2.class}' AND actor_id=#{@follower2.id} ALLOW FILTERING").rows.to_a
        # assert_empty Socialization.redis.smembers backward_key(@followable1)
        # assert_empty Socialization.redis.smembers backward_key(@follower2)
        # assert_empty Socialization.redis.smembers forward_key(@follower1)
      end
    end

  end

  # Helpers
  def assert_match_follower(follow_record, follower)
    assert follow_record.follower_type ==  follower.class.to_s && follow_record.follower_id == follower.id
  end

  def assert_match_followable(follow_record, followable)
    assert follow_record.followable_type ==  followable.class.to_s && follow_record.followable_id == followable.id
  end

  def forward_key(followable)
    Socialization::CassandraStores::Follow.send(:forward_table_name)
  end

  def backward_key(follower)
    Socialization::CassandraStores::Follow.send(:backward_table_name)
  end
end
