require File.expand_path('../../test_helper', __FILE__)

class FollowableTest < TestCase
  include Assertions
  context "Followable" do
    setup do
      # @follower = ImAFollower.new
      @follower = ImAFollower.create
      @followable = ImAFollowable.create
    end

    context "#is_followable?" do
      should "return true" do
        assert_true @followable.is_followable?
      end
    end

    context "#followable?" do
      should "return true" do
        assert_true @followable.followable?
      end
    end

    context "#followed_by?" do
      should "not accept non-followers" do
        assert_raises(Socialization::ArgumentError) { @followable.followed_by?(:foo) }
      end

      should "call $Follow.follows?" do
        Minitest::Mock.new.expect(:check, false) do
          $Follow.follows?(@follower, @followable)
        end
        # assert_send([$Follow, :follows?, *[@follower, @followable]])
        @followable.followed_by?(@follower)
      end
    end

    context "#followers" do
      should "call $Follow.followers" do
        assert_send([$Follow, :followers, *[@followable, @follower.class, { :foo => :bar }]])
        @followable.followers(@follower.class, { :foo => :bar })
      end
    end

    context "#followers_relation" do
      should "call $Follow.followers_relation" do
        assert_send([$Follow, :followers_relation, *[@followable, @follower.class, { :foo => :bar }]])
        @followable.followers_relation(@follower.class, { :foo => :bar })
      end
    end

    context "deleting a followable" do
      setup do
        @follower = ImAFollower.create
        @follower.follow!(@followable)
      end

      should "remove follow relationships" do
        assert_send([Socialization.follow_model, :remove_followers, *[@followable]])
        @followable.destroy
      end
    end

  end
end
