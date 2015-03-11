module ActiveRecord
  class Base
    def is_commentable?
      false
    end
    alias commentable? is_commentable?
  end
end

module Socialization
  module Commentable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.comment_model.remove_commenters(self) }

      # Specifies if self can be commented.
      #
      # @return [Boolean]
      def is_commentable?
        true
      end
      alias commentable? is_commentable?

      # Specifies if self is commented by a {commenter} object.
      #
      # @return [Boolean]
      def commented_by?(commenter)
        raise Socialization::ArgumentError, "#{commenter} is not commenter!"  unless commenter.respond_to?(:is_commenter?) && commenter.is_commenter?
        Socialization.comment_model.comments?(commenter, self)
      end

      # Returns an array of {commenter}s commenting self.
      #
      # @param [Class] klass the {commenter} class to be included. e.g. `User`
      # @return [Array<commenter, Numeric>] An array of commenter objects or IDs
      def commenters(klass, opts = {})
        Socialization.comment_model.commenters(self, klass, opts)
      end

      # Returns a scope of the {commenter}s commenting self.
      #
      # @param [Class] klass the {commenter} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def commenters_relation(klass, opts = {})
        Socialization.comment_model.commenters_relation(self, klass, opts)
      end

    end
  end
end
