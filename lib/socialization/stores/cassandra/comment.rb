module Socialization
  module CassandraStores
    class Comment< Socialization::CassandraStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Like
      extend Socialization::CassandraStores::Mixins::Base

      class << self
        def forward_table_name
          nil
        end
        def backward_table_name
          "comments"
        end
        def counter_forward_table_name
          nil
        end
        def counter_backward_table_name
          "comment_counter"
        end
        alias_method :comment!, :relation!;                           public :comment!
        alias_method :remove_comments, :remove_actor_relations;       public :remove_comments
        alias_method :comments_cnt, :actors_cnt;                      public :comments_cnt
      end

    end
  end
end
