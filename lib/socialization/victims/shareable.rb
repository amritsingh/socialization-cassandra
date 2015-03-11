module ActiveRecord
  class Base
    def is_shareable?
      false
    end
    alias shareable? is_shareable?
  end
end

module Socialization
  module Shareable
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.share_model.remove_sharers(self) }

      # Specifies if self can be shared.
      #
      # @return [Boolean]
      def is_shareable?
        true
      end
      alias shareable? is_shareable?

      # Specifies if self is shared by a {sharer} object.
      #
      # @return [Boolean]
      def shared_by?(sharer)
        raise Socialization::ArgumentError, "#{sharer} is not sharer!"  unless sharer.respond_to?(:is_sharer?) && sharer.is_sharer?
        Socialization.share_model.shares?(sharer, self)
      end

      # Returns an array of {sharer}s shareing self.
      #
      # @param [Class] klass the {sharer} class to be included. e.g. `User`
      # @return [Array<sharer, Numeric>] An array of sharer objects or IDs
      def sharers(klass, opts = {})
        Socialization.share_model.sharers(self, klass, opts)
      end

      # Returns a scope of the {sharer}s sharing self.
      #
      # @param [Class] klass the {sharer} class to be included in the scope. e.g. `User`
      # @return ActiveRecord::Relation
      def sharers_relation(klass, opts = {})
        Socialization.share_model.sharers_relation(self, klass, opts)
      end

    end
  end
end
