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
      @cassandra = Cassandra.cluster if @cassandra.nil?
      @cas_keyspace = 'test' if @cas_keyspace.nil?
      @cassandra.connect @cas_keyspace
    end
  end
end
