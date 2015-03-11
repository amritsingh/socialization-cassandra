module Socialization
  class << self
    def follow_model
      if @follow_model
        @follow_model
      else
        ::Follow
      end
    end

    def follow_model=(klass)
      @follow_model = klass
    end

    def like_model
      if @like_model
        @like_model
      else
        ::Like
      end
    end

    def like_model=(klass)
      @like_model = klass
    end

    def comment_model
      if @comment_model
        @comment_model
      else
        ::Comment
      end
    end

    def comment_model=(klass)
      @comment_model = klass
    end

    def share_model
      if @share_model
        @share_model
      else
        ::Share
      end
    end

    def share_model=(klass)
      @share_model = klass
    end
  end
end
