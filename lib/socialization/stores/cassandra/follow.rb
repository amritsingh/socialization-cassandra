module Socialization
  module CassandraStores
    class Follow < Socialization::CassandraStores::Base
      extend Socialization::Stores::Mixins::Base
      extend Socialization::Stores::Mixins::Follow
      extend Socialization::CassandraStores::Mixins::Base

      class << self
        def forward_table_name
          "followings"
        end
        def backward_table_name
          "followers"
        end
        def counter_forward_table_name
          "following_counter"
        end
        def counter_backward_table_name
          "follower_counter"
        end
        alias_method :follow!, :relation!;                            public :follow!
        alias_method :unfollow!, :unrelation!;                        public :unfollow!
        alias_method :follows?, :relation?;                           public :follows?
        alias_method :followers_relation, :actors_relation;           public :followers_relation
        alias_method :followers, :actors;                             public :followers
        alias_method :followables_relation, :victims_relation;        public :followables_relation
        alias_method :followables, :victims;                          public :followables
        alias_method :remove_followers, :remove_actor_relations;      public :remove_followers
        alias_method :remove_followables, :remove_victim_relations;   public :remove_followables
        alias_method :followers_cnt, :actors_cnt;                     public :followers_cnt
        alias_method :following_cnt, :victims_cnt;                    public :following_cnt
      end

    end
  end
end
