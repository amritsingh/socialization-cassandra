module Socialization
  class << self
    def cassandra
      @cassandra
    end

    def cassandra=(cassandra)
      @cassandra = cassandra
    end

    def keyspace
      @cas_keyspace
    end

    def keyspace=(keyspace)
      @cas_keyspace = keyspace
    end

    def cassandra_session
      @cassandra.use @cas_keyspace if @cassandra.keyspace != @cas_keyspace
      @cassandra
    end
  end
end
