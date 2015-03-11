require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class FollowerTest < TestCase
  include Assertions
  context "Follower" do
    setup do
      # @follower = ImAFollower.new
      @follower = ImAFollower.create
      @followable = ImAFollowable.create
    end

    context "#is_follower?" do
      should "return true" do
        assert_true @follower.is_follower?
      end
    end

    context "#follower?" do
      should "return true" do
        assert_true @follower.follower?
      end
    end

    context "#follow!" do
      should "not accept non-followables" do
        assert_raises(Socialization::ArgumentError) { @follower.follow!(:foo) }
      end

      should "call $Follow.follow!" do
        assert_send([$Follow, :follow!, *[@follower, @followable]])
        @follower.follow!(@followable)
      end
    end

    context "#unfollow!" do
      should "not accept non-followables" do
        assert_raises(Socialization::ArgumentError) { @follower.unfollow!(:foo) }
      end

      should "call $Follow.follow!" do
        Minitest::Mock.new.expect(:check, true) do
          $Follow.unfollows!(@follower, @followable)
        end
        @follower.unfollow!(@followable)
      end
    end

    context "#toggle_follow!" do
      should "not accept non-followables" do
        assert_raises(Socialization::ArgumentError) { @follower.unfollow!(:foo) }
      end

      should "unfollow when following" do
        @follower.follow!(@followable)
        Minitest::Mock.new.expect(:check, true) do
          @follower.follows?(@followable)
        end
        # @follower.expect :follows?, true, *[@followable]
        # assert_send([@follower, :follows?, *[@followable]])
        assert_send([@follower, :unfollow!, *[@followable]])
        @follower.toggle_follow!(@followable)
      end

      should "follow when not following" do
        Minitest::Mock.new.expect(:check, false) do
          @follower.follows?(@followable)
        end
        # !assert_send([@follower, :follows?, *[@followable]])
        # assert_send([@follower, :follows?, *[@followable]])
        @follower.toggle_follow!(@followable)
      end
    end

    context "#follows?" do
      should "not accept non-followables" do
        assert_raises(Socialization::ArgumentError) { @follower.unfollow!(:foo) }
      end

      should "call $Follow.follows?" do
        Minitest::Mock.new.expect(:check, false) do
          $Follow.follows?(@follower, @followable)
        end
        # assert_send([$Follow, :follows?, *[@follower, @followable]])
        @follower.follows?(@followable)
      end
    end

    context "#followables" do
      should "call $Follow.followables" do
        assert_send([$Follow, :followables, *[@follower, @followable.class, { :foo => :bar  }]])
        @follower.followables(@followable.class, { :foo => :bar })
      end
    end

    context "#followees" do
      should "call $Follow.followables" do
        assert_send([$Follow, :followables, *[@follower, @followable.class, { :foo => :bar  }]])
        @follower.followees(@followable.class, { :foo => :bar })
      end
    end

    context "#followables_relation" do
      should "call $Follow.followables_relation" do
        assert_send([$Follow, :followables_relation, *[@follower, @followable.class, { :foo => :bar  }]])
        @follower.followables_relation(@followable.class, { :foo => :bar })
      end
    end

    context "#followees_relation" do
      should "call $Follow.followables_relation" do
        assert_send([$Follow, :followables_relation, *[@follower, @followable.class, { :foo => :bar  }]])
        @follower.followees_relation(@followable.class, { :foo => :bar })
      end
    end

    context "deleting a follower" do
      setup do
        @follower = ImAFollower.create
        @follower.follow!(@followable)
      end

      should "remove follow relationships" do
        assert_send([Socialization.follow_model, :remove_followables, *[@follower]])
        @follower.destroy
      end
    end

  end
end
