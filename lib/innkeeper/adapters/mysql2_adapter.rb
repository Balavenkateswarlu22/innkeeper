require 'innkeeper/adapters/abstract_adapter'
require 'digest'

module Innkeeper
  module Adapters
    class Mysql2Adapter < AbstractAdapter
      def switch_tenant(config)
        difference = current_difference_from(config)

        if difference[:host]
          connection_switch!(config)
        else
          simple_switch(config) if difference[:database]
        end
      end

      def create_tenant!(config)
        Innkeeper.connection.create_database(config[:database], config)
      end

      def simple_switch(config)
        Innkeeper.connection.execute("use `#{config[:database]}`")
      rescue ActiveRecord::StatementInvalid => exception
        raise_connect_error!(config[:database], exception)
      end

      def connection_specification_name(config)
        if Innkeeper.pool_per_config
          "_innkeeper_#{config.hash}".to_sym
        else
          host_hash = Digest::MD5.hexdigest(config[:host] || config[:url] || "127.0.0.1")
          "_innkeeper_#{host_hash}_#{config[:adapter]}".to_sym
        end
      end

      private
        def database_exists?(database)
          result = Innkeeper.connection.exec_query(<<-SQL).try(:first)
            SELECT 1 AS `exists`
            FROM INFORMATION_SCHEMA.SCHEMATA
            WHERE SCHEMA_NAME = #{Innkeeper.connection.quote(database)}
          SQL
          result.present? && result['exists'] == 1
        end
    end
  end
end
