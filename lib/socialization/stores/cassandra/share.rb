module Socialization
  module CassandraStores
    class Share < Socialization::CassandraStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Like
      extend Socialization::CassandraStores::Mixins::Base

      class << self
        def forward_table_name
          nil
        end
        def backward_table_name
          "shares"
        end
        def counter_forward_table_name
          nil
        end
        def counter_backward_table_name
          "share_counter"
        end
        alias_method :share!, :relation!;                           public :share!
        alias_method :remove_shares, :remove_actor_relations;       public :remove_shares
        alias_method :shares_cnt, :actors_cnt;                      public :shares_cnt
      end

    end
  end
end
