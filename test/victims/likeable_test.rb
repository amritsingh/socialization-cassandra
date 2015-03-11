require File.expand_path(File.dirname(__FILE__))+'/../test_helper'

class LikeableTest < TestCase
  include Assertions
  context "Likeable" do
    setup do
      #@liker = ImALiker.new
      @liker = ImALiker.create
      @likeable = ImALikeable.create
    end

    context "#is_likeable?" do
      should "return true" do
        assert @likeable.is_likeable?
      end
    end

    context "#likeable?" do
      should "return true" do
        assert @likeable.likeable?
      end
    end

    context "#liked_by?" do
      should "not accept non-likers" do
        assert_raises(Socialization::ArgumentError) { @likeable.liked_by?(:foo) }
      end

      # should "call $Like.likes?" do
      #   # $Like.expect(:likes?).with(@liker, @likeable).once
      #   assert_send([$Like, :likes?, *[@liker, @likeable]])
      #   @likeable.liked_by?(@liker)
      # end
    end

    context "#likers" do
      should "call $Like.likers" do
        # $Like.expect(:likers).with(@likeable, @liker.class, { :foo => :bar })
        assert_send([$Like, :likers, *[@likeable, @liker.class, { :foo => :bar  }]])
        @likeable.likers(@liker.class, { :foo => :bar })
      end
    end

    context "#likers_relation" do
      should "call $Like.likers_relation" do
        # $Like.expect(:likers_relation).with(@likeable, @liker.class, { :foo => :bar })
        assert_send([$Like, :likers_relation, *[@likeable, @liker.class, { :foo => :bar }]])
        @likeable.likers_relation(@liker.class, { :foo => :bar })
      end
    end

    context "deleting a likeable" do
      setup do
        @liker = ImALiker.create
        @liker.save!
        @liker.like!(@likeable)
      end

      should "remove like relationships" do
        assert_send([Socialization.like_model, :remove_likers, *[@likeable]])
        # Socialization.like_model.expect(:remove_likers).with(@likeable)
        @likeable.destroy
      end
    end

  end
end
