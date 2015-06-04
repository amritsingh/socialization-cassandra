class SocializationCassandraMigrations

  MIGRATIONS = [

    # likes

    "CREATE TABLE likes (
      actor_type varchar,
      actor_id bigint,
      victim_id bigint,
      victim_type varchar,
      created_at bigint,
      PRIMARY KEY ((actor_type, actor_id), created_at)
    );",

    "CREATE INDEX ON likes (victim_type)",
    "CREATE INDEX ON likes (victim_id)",

    "CREATE TABLE likers (
      actor_type varchar,
      actor_id bigint,
      victim_id bigint,
      victim_type varchar,
      created_at bigint,
      PRIMARY KEY ((victim_type, victim_id), created_at)
    );",

    "CREATE INDEX ON likers (actor_type)",
    "CREATE INDEX ON likers (actor_id)",

    "CREATE TABLE liker_counter (
      victim_id bigint,
      victim_type varchar,
      cnt counter,
      PRIMARY KEY (victim_type, victim_id)
    );",

    # follow

    "CREATE TABLE followings (
      actor_type varchar,
      actor_id bigint,
      victim_id bigint,
      victim_type varchar,
      created_at bigint,
      PRIMARY KEY ((actor_type, actor_id), created_at)
    );",

    "CREATE INDEX ON followings (victim_type)",
    "CREATE INDEX ON followings (victim_id)",

    "CREATE TABLE followers (
      actor_type varchar,
      actor_id bigint,
      victim_id bigint,
      victim_type varchar,
      created_at bigint,
      PRIMARY KEY ((victim_type, victim_id), created_at)
    );",

    "CREATE INDEX ON followers (actor_type)",
    "CREATE INDEX ON followers (actor_id)",

    "CREATE TABLE following_counter (
      actor_id bigint,
      actor_type varchar,
      cnt counter,
      PRIMARY KEY (actor_type, actor_id)
    );",

    "CREATE TABLE follower_counter (
      victim_id bigint,
      victim_type varchar,
      cnt counter,
      PRIMARY KEY (victim_type, victim_id)
    );",

    # Comments 

    "CREATE TABLE comments (
      actor_type varchar,
      actor_id bigint,
      victim_id bigint,
      victim_type varchar,
      created_at bigint,
      txt text,
      PRIMARY KEY ((victim_type, victim_id), created_at)
    );",

    "CREATE TABLE comment_counter (
      victim_id bigint,
      victim_type varchar,
      cnt counter,
      PRIMARY KEY (victim_type, victim_id)
    );",

    # Share

    "CREATE TABLE shares (
      actor_type varchar,
      actor_id bigint,
      victim_id bigint,
      victim_type varchar,
      networks set<text>,
      created_at bigint,
      txt text,
      PRIMARY KEY ((victim_type, victim_id), created_at)
    );",

    "CREATE TABLE share_counter (
      victim_id bigint,
      victim_type varchar,
      cnt counter,
      PRIMARY KEY (victim_type, victim_id)
    );"

  ]

end

mespace :socialization do
  desc "Socialization Cassandra Migrations"
  task(:migrate => :environment) do
    SocializationCassandraMigrations::MIGRATIONS.each do |m|
      begin
        Socialization.cassandra_session.execute(m)
      rescue Cassandra::Errors::AlreadyExistsError => e
        next
      end
    end
  end
end

