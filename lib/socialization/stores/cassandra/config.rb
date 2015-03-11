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
      @cassandra_session = cassandra.connect(keyspace)
    end

    def cassandra_session
      @cassandra_session ||= @cassandra.connect(@cas_keyspace)
    rescue
      @cassandra = Cassandra.cluster
      @cas_keyspace = 'test'
      @cassandra_session ||= @cassandra.connect(@cas_keyspace)
    end

  end
end
