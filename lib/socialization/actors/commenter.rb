module Socialization
  module Commenter
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.comment_model.remove_commentables(self) }

      # Specifies if self can comment {Commentable} objects.
      #
      # @return [Boolean]
      def is_commenter?
        true
      end
      alias commenter? is_commenter?

      # Create a new {Comment comment} relationship.
      #
      # @param [Commentable] commentable the object to be commented.
      # @return [Boolean]
      def comment!(commentable)
        raise Socialization::ArgumentError, "#{commentable} is not commentable!"  unless commentable.respond_to?(:is_commentable?) && commentable.is_commentable?
        Socialization.comment_model.comment!(self, commentable)
      end

      # Delete a {Comment comment} relationship.
      #
      # @param [Commentable] commentable the object to uncomment.
      # @return [Boolean]
      def uncomment!(commentable)
        raise Socialization::ArgumentError, "#{commentable} is not commentable!" unless commentable.respond_to?(:is_commentable?) && commentable.is_commentable?
        Socialization.comment_model.uncomment!(self, commentable)
      end

      # Toggles a {Comment comment} relationship.
      #
      # @param [Commentable] commentable the object to comment/uncomment.
      # @return [Boolean]
      def toggle_comment!(commentable)
        raise Socialization::ArgumentError, "#{commentable} is not commentable!" unless commentable.respond_to?(:is_commentable?) && commentable.is_commentable?
        if comments?(commentable)
          uncomment!(commentable)
          false
        else
          comment!(commentable)
          true
        end
      end

      # Specifies if self comments a {Commentable} object.
      #
      # @param [Commentable] commentable the {Commentable} object to test against.
      # @return [Boolean]
      def comments?(commentable)
        raise Socialization::ArgumentError, "#{commentable} is not commentable!" unless commentable.respond_to?(:is_commentable?) && commentable.is_commentable?
        Socialization.comment_model.comments?(self, commentable)
      end

      # Returns all the commentables of a certain type that are commented by self
      #
      # @params [Commentable] klass the type of {Commentable} you want
      # @params [Hash] opts a hash of options
      # @return [Array<Commentable, Numeric>] An array of Commentable objects or IDs
      def commentables(klass, opts = {})
        Socialization.comment_model.commentables(self, klass, opts)
      end
      alias :commentees :commentables

      # Returns a relation for all the commentables of a certain type that are commented by self
      #
      # @params [Commentable] klass the type of {Commentable} you want
      # @params [Hash] opts a hash of options
      # @return ActiveRecord::Relation
      def commentables_relation(klass, opts = {})
        Socialization.comment_model.commentables_relation(self, klass, opts)
      end
      alias :commentees_relation :commentables_relation
    end
  end
end
