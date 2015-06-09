module Socialization
  module Sharer
    extend ActiveSupport::Concern

    included do
      after_destroy { Socialization.share_model.remove_shareables(self) }

      # Specifies if self can share {Shareable} objects.
      #
      # @return [Boolean]
      def is_sharer?
        true
      end
      alias sharer? is_sharer?

      # Create a new {Share share} relationship.
      #
      # @param [Shareable] shareable the object to be shared.
      # @return [Boolean]
      def share!(shareable, opts = {})
        raise Socialization::ArgumentError, "#{shareable} is not shareable!"  unless shareable.respond_to?(:is_shareable?) && shareable.is_shareable?
        Socialization.share_model.share!(self, shareable, opts)
      end

      # Delete a {Share share} relationship.
      #
      # @param [Shareable] shareable the object to unshare.
      # @return [Boolean]
      def unshare!(shareable)
        raise Socialization::ArgumentError, "#{shareable} is not shareable!" unless shareable.respond_to?(:is_shareable?) && shareable.is_shareable?
        Socialization.share_model.unshare!(self, shareable)
      end

      # Toggles a {Share share} relationship.
      #
      # @param [Shareable] shareable the object to share/unshare.
      # @return [Boolean]
      def toggle_share!(shareable, opts = {})
        raise Socialization::ArgumentError, "#{shareable} is not shareable!" unless shareable.respond_to?(:is_shareable?) && shareable.is_shareable?
        if shares?(shareable)
          unshare!(shareable)
          false
        else
          share!(shareable, opts)
          true
        end
      end

      # Specifies if self shares a {Shareable} object.
      #
      # @param [Shareable] shareable the {Shareable} object to test against.
      # @return [Boolean]
      def shares?(shareable)
        raise Socialization::ArgumentError, "#{shareable} is not shareable!" unless shareable.respond_to?(:is_shareable?) && shareable.is_shareable?
        Socialization.share_model.shares?(self, shareable)
      end

      # Returns all the shareables of a certain type that are shared by self
      #
      # @params [Shareable] klass the type of {Shareable} you want
      # @params [Hash] opts a hash of options
      # @return [Array<Shareable, Numeric>] An array of Shareable objects or IDs
      def shareables(klass, opts = {})
        Socialization.share_model.shareables(self, klass, opts)
      end
      alias :sharees :shareables

      # Returns a relation for all the shareables of a certain type that are shared by self
      #
      # @params [Shareable] klass the type of {Shareable} you want
      # @params [Hash] opts a hash of options
      # @return ActiveRecord::Relation
      def shareables_relation(klass, opts = {})
        Socialization.share_model.shareables_relation(self, klass, opts)
      end
      alias :sharees_relation :shareables_relation
    end
  end
end
