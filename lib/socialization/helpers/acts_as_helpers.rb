require 'active_support/concern'

module Socialization
  module ActsAsHelpers
    extend ActiveSupport::Concern

    module ClassMethods
      # Make the current class a {Socialization::Follower}
      def acts_as_follower(opts = {})
        include Socialization::Follower
      end

      # Make the current class a {Socialization::Followable}
      def acts_as_followable(opts = {})
        include Socialization::Followable
      end

      # Make the current class a {Socialization::Liker}
      def acts_as_liker(opts = {})
        include Socialization::Liker
      end

      # Make the current class a {Socialization::Likeable}
      def acts_as_likeable(opts = {})
        include Socialization::Likeable
      end

      # Make the current class a {Socialization::Commenter}
      def acts_as_commenter(opts = {})
        include Socialization::Commenter
      end

      # Make the current class a {Socialization::Commentable}
      def acts_as_commentable(opts = {})
        include Socialization::Commentable
      end

      # Make the current class a {Socialization::Sharer}
      def acts_as_sharer(opts = {})
        include Socialization::Sharer
      end

      # Make the current class a {Socialization::Shareable}
      def acts_as_shareable(opts = {})
        include Socialization::Shareable
      end
    end
  end
end
