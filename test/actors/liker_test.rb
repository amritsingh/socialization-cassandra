require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class LikerTest < TestCase
  include Assertions
  context "Liker" do
    setup do
      # @liker = ImALiker.new
      @liker = ImALiker.create
      @likeable = ImALikeable.create
    end

    context "#is_liker?" do
      should "return true" do
        assert_true @liker.is_liker?
      end
    end

    context "#liker?" do
      should "return true" do
        assert_true @liker.liker?
      end
    end

    context "#like!" do
      should "not accept non-likeables" do
        assert_raises(Socialization::ArgumentError) { @liker.like!(:foo) }
      end

      should "call $Like.like!" do
        assert_send([$Like, :like!, *[@liker, @likeable]])
        @liker.like!(@likeable)
      end
    end

    context "#unlike!" do
      should "not accept non-likeables" do
        assert_raises(Socialization::ArgumentError) { @liker.unlike!(:foo) }
      end

      should "call $Like.like!" do
        Minitest::Mock.new.expect(:check, false) do
          $Like.unlike!(@liker, @likeables)
        end
        @liker.unlike!(@likeable)
      end
    end

    context "#toggle_like!" do
      should "not accept non-likeables" do
        assert_raises(Socialization::ArgumentError) { @liker.unlike!(:foo) }
      end

      should "unlike when likeing" do
        @liker.like!(@likeable)
        Minitest::Mock.new.expect(:check, true) do
          @liker.likes?(@likeables)
        end
        Minitest::Mock.new.expect(:check, true) do
          @liker.unlike!(@likeables)
        end
        # assert_send([@liker, :unlike!, *[@likeable]])
        @liker.toggle_like!(@likeable)
      end

      should "like when not likeing" do
        Minitest::Mock.new.expect(:check, false) do
          @liker.likes?(@likeables)
        end
        assert_send([@liker, :like!, *[@likeable]])
        @liker.toggle_like!(@likeable)
      end
    end

    context "#likes?" do
      should "not accept non-likeables" do
        assert_raises(Socialization::ArgumentError) { @liker.unlike!(:foo) }
      end

      should "call $Like.likes?" do
        Minitest::Mock.new.expect(:check, false) do
          $Like.likes?(@liker, @likeables)
        end
        # assert_send([$Like, :likes?, *[@liker, @likeable]])
        @liker.likes?(@likeable)
      end
    end

    context "#likeables" do
      should "call $Like.likeables" do
        assert_send([$Like, :likeables, *[@liker, @likeable.class, { :foo => :bar }]])
        @liker.likeables(@likeable.class, { :foo => :bar })
      end
    end

    context "#likees" do
      should "call $Like.likeables" do
        assert_send([$Like, :likeables, *[@liker, @likeable.class, { :foo => :bar }]])
        @liker.likees(@likeable.class, { :foo => :bar })
      end
    end

    context "#likeables_relation" do
      should "call $Follow.likeables_relation" do
        assert_send([$Like, :likeables_relation, *[@liker, @likeable.class, { :foo => :bar }]])
        @liker.likeables_relation(@likeable.class, { :foo => :bar })
      end
    end

    context "#likees_relation" do
      should "call $Follow.likeables_relation" do
        assert_send([$Like, :likeables_relation, *[@liker, @likeable.class, { :foo => :bar }]])
        @liker.likees_relation(@likeable.class, { :foo => :bar })
      end
    end

    should "remove like relationships" do
      assert_send([Socialization.like_model, :remove_likeables, *[@liker]])
      @liker.destroy
    end
  end
end
