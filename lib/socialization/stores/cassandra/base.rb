module Socialization
  module CassandraStores
    class Base

      class << self
      protected
        def actors(victim, klass, options = {})
          if options[:pluck]
            query_result = Socialization.cassandra_session.execute("SELECT actor_type, actor_id from #{backward_table_name} WHERE victim_type = '#{victim.class}' AND victim_id = #{victim.id}")
            return [] if query_result.blank? || query_result.rows.blank?
            query_result.rows.collect {|i| i['actor_id'] if i['actor_type'] == klass.to_s}
          else
            actors_relation(victim, klass, options).to_a
          end
        end

        def actors_cnt(victim, klass, options = {})
          return 0 if counter_backward_table_name.nil?
          query_result = Socialization.cassandra_session.execute("SELECT cnt from #{counter_backward_table_name} WHERE victim_type = '#{victim.class}' AND victim_id = #{victim.id}")
          return 0 if query_result.blank? || query_result.rows.blank?
          query_result.rows.first['cnt']
        end

        def actors_relation(victim, klass, options = {})
          ids = actors(victim, klass, :pluck => :id)
          klass.where("#{klass.table_name}.id IN (?)", ids)
        end

        def victims_relation(actor, klass, options = {})
          ids = victims(actor, klass, :pluck => :id)
          klass.where("#{klass.table_name}.id IN (?)", ids)
        end

        def victims(actor, klass, options = {})
          if options[:pluck]
            query_result = Socialization.cassandra_session.execute("SELECT victim_type, victim_id from #{forward_table_name} WHERE actor_type='#{actor.class}' AND actor_id=#{actor.id}")
            return [] if query_result.blank? || query_result.rows.blank?
            query_result.rows.collect {|i| i['victim_id'] if i['victim_type'] == klass.to_s}
          else
            victims_relation(actor, klass, options).to_a
          end
        end

        def victims_cnt(actor, klass, options = {})
          return 0 if counter_forward_table_name.nil?
          query_result = Socialization.cassandra_session.execute("SELECT cnt from #{counter_forward_table_name} WHERE actor_type = '#{actor.class}' AND actor_id = #{actor.id}")
          return 0 if query_result.blank? || query_result.rows.blank?
          query_result.rows.first['cnt']
        end

        def relation!(actor, victim, options = {})
          unless options[:skip_check] || relation?(actor, victim)
            add_new_entry(actor, victim, {})
            call_after_create_hooks(actor, victim)
            true
          else
            false
          end
        end

        def unrelation!(actor, victim, options = {})
          if options[:skip_check] || relation?(actor, victim)
            delete_entry(actor, victim, {})
            call_after_destroy_hooks(actor, victim)
            true
          else
            false
          end
        end

        def relation?(actor, victim)
          if backward_table_name
            query_result = Socialization.cassandra_session.execute("SELECT * FROM #{backward_table_name} WHERE victim_type = '#{victim.class}' AND victim_id = #{victim.id} AND actor_type = '#{actor.class}' AND actor_id = #{actor.id} ALLOW FILTERING")
            !query_result.rows.to_a.empty?
          else
            false
          end
        end

        def remove_actor_relations(victim)
          query_result = Socialization.cassandra_session.execute("SELECT * FROM #{backward_table_name} WHERE victim_type='#{victim.class}' AND victim_id=#{victim.id}")
          if query_result.present? && query_result.rows.present?
            query_result.rows.to_a.each do |i|
              delete_entry_from_forward_table_name(i['actor_type'], i['actor_id'], victim.class, victim.id)
              Socialization.cassandra_session.execute("DELETE FROM #{backward_table_name} WHERE victim_type='#{victim.class}' AND victim_id=#{victim.id} AND created_at=#{i["created_at"]}")
            end
          end
          # puts "DELETE FROM #{backward_table_name} WHERE victim_type=#{victim.class} AND victim_id=#{victim.id}"
          # Socialization.cassandra_session.execute("DELETE FROM #{backward_table_name} WHERE victim_type=#{victim.class} AND victim_id=#{victim.id}")
          true
        end

        def remove_victim_relations(actor)
          query_result = Socialization.cassandra_session.execute("SELECT * FROM #{forward_table_name} WHERE actor_type='#{actor.class}' AND actor_id=#{actor.id}")
          if query_result.present? && query_result.rows.present?
            query_result.rows.to_a.each do |i|
              delete_entry_from_backward_table_name(actor.class, actor.id, i['victim_type'], i['victim_id'])
              Socialization.cassandra_session.execute("DELETE FROM #{forward_table_name} WHERE actor_type='#{actor.class}' AND actor_id=#{actor.id} AND created_at=#{i["created_at"]}")
            end
          end
          # Socialization.cassandra_session.execute("DELETE FROM #{forward_table_name} WHERE actor_type='#{actor.class}' AND actor_id=#{actor.id}")
          true
        end


      private

        def add_new_entry(actor, victim, options={})
          [forward_table_name, backward_table_name].uniq.each do |table_name|
            query_columns = "actor_type, actor_id, victim_type, victim_id, created_at"
            query_values = "'#{actor.class}', #{actor.id}, '#{victim.class}', #{victim.id}, #{(Time.now.to_f * 100000).to_i}"
            if options[:text]
              query_columns += ", text"
              query_values += ", '#{options[:text]}'"
            end
            if options[:networks] && options[:networks].is_a?(Array)
              query_columns += ", networks"
              query_values += ", #{options[:networks].to_s.gsub('[', '{').gsub(']', '}')}"
            end
            Socialization.cassandra_session.execute("INSERT INTO #{table_name} (#{query_columns}) VALUES (#{query_values})")
          end
          Socialization.cassandra_session.execute("UPDATE #{counter_forward_table_name} SET cnt = cnt + 1 WHERE actor_type = '#{actor.class}' AND actor_id = #{actor.id}") if counter_forward_table_name
          Socialization.cassandra_session.execute("UPDATE #{counter_backward_table_name} SET cnt = cnt + 1 WHERE victim_type = '#{victim.class}' AND victim_id = #{victim.id}") if counter_backward_table_name
        end

        def delete_entry_from_forward_table_name(actor_type, actor_id, victim_type, victim_id)
          row = Socialization.cassandra_session.execute("SELECT * FROM #{forward_table_name} WHERE actor_type='#{actor_type}' AND actor_id=#{actor_id} AND victim_type='#{victim_type}' AND victim_id=#{victim_id} ALLOW FILTERING").rows.first
          Socialization.cassandra_session.execute("DELETE FROM #{forward_table_name} WHERE actor_type='#{actor_type}' AND actor_id=#{actor_id} AND created_at=#{row["created_at"]}") # if row
          Socialization.cassandra_session.execute("UPDATE #{counter_forward_table_name} SET cnt = cnt - 1 WHERE actor_type = '#{actor_type}' AND actor_id = #{actor_id}") if counter_forward_table_name
        end

        def delete_entry_from_backward_table_name(actor_type, actor_id, victim_type, victim_id)
          row = Socialization.cassandra_session.execute("SELECT * FROM #{backward_table_name} WHERE actor_type='#{actor_type}' AND actor_id=#{actor_id} AND victim_type='#{victim_type}' AND victim_id=#{victim_id} ALLOW FILTERING").rows.to_a.first
          Socialization.cassandra_session.execute("DELETE FROM #{backward_table_name} WHERE victim_type='#{victim_type}' AND victim_id=#{victim_id} AND created_at=#{row["created_at"]}") if row
          Socialization.cassandra_session.execute("UPDATE #{counter_forward_table_name} SET cnt = cnt - 1 WHERE actor_type = '#{actor_type}' AND actor_id = #{actor_id}") if counter_forward_table_name
        end

        def delete_entry(actor, victim, options={})
          delete_entry_from_forward_table_name(actor.class, actor.id, victim.class, victim.id) if forward_table_name
          delete_entry_from_backward_table_name(actor.class, actor.id, victim.class, victim.id) if backward_table_name
          Socialization.cassandra_session.execute("UPDATE #{counter_forward_table_name} SET cnt = cnt - 1 WHERE actor_type = '#{actor.class}' AND actor_id = #{actor.id}") if counter_forward_table_name
          Socialization.cassandra_session.execute("UPDATE #{counter_backward_table_name} SET cnt = cnt - 1 WHERE victim_type = '#{victim.class}' AND victim_id = #{victim.id}") if counter_backward_table_name
        end

      end # class << self

    end # Base
  end # CassandraStores
end # Socialization
