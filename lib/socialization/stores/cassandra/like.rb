module Socialization
  module CassandraStores
    class Like < Socialization::CassandraStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Like
      extend Socialization::CassandraStores::Mixins::Base

      class << self
        def forward_table_name
          "likes"
        end
        def backward_table_name
          "likers"
        end
        def counter_forward_table_name
          nil
        end
        def counter_backward_table_name
          "liker_counter"
        end
        alias_method :like!, :relation!;                          public :like!
        alias_method :unlike!, :unrelation!;                      public :unlike!
        alias_method :likes?, :relation?;                         public :likes?
        alias_method :likers_relation, :actors_relation;          public :likers_relation
        alias_method :likers, :actors;                            public :likers
        alias_method :likeables_relation, :victims_relation;      public :likeables_relation
        alias_method :likeables, :victims;                        public :likeables
        alias_method :remove_likers, :remove_actor_relations;     public :remove_likers
        alias_method :remove_likeables, :remove_victim_relations; public :remove_likeables
        alias_method :likers_cnt, :actors_cnt;                    public :likers_cnt
      end

    end
  end
end
