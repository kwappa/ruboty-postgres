require 'pg'

module Ruboty
  module Brains
    class Postgres < Base
      # sleeps this minutes between save
      SAVE_INTERVAL = 10

      attr_reader :thread

      env :POSTGRES_HOST,      'host of postgres (default: localhost)',       optional: true
      env :POSTGRES_PORT,      'port number of postgres (default: 5432)',     optional: true
      env :POSTGRES_USER,      'user name of postgres',                       optional: false
      env :POSTGRES_PASSWORD,  'password of postgres',                        optional: false
      env :POSTGRES_DBNAME,    'database name of postgres',                   optional: false
      env :POSTGRES_NAMESPACE, 'relation name of postgres (default: ruboty)', optional: true
      env :POSTGRES_BOTNAME,   'name of your ruboty (default: ruboty)',       optional: true

      def initialize
        super
        @thread = Thread.new { sync }
        @thread.abort_on_exception = true
      end

      def data
        @data ||= load || {}
      end

      # Override.
      def validate!
        super
        Ruboty.die("#{self.class.usage}") unless host
      end

      private

      def save
        sql = "UPDATE #{namespace} SET marshal = $1 WHERE botname = $2;"
        str = connection.escape_bytea(Marshal.dump(data))
        connection.prepare('save_statement', sql)
        connection.exec_prepared('save_statement', [str, botname])
      end

      def load
        sql = "SELECT marshal FROM #{namespace} WHERE botname = $1;"
        connection.prepare('load_statement', sql)
        result = connection.exec_prepared('load_statement', [botname])
        if result.count == 0
          str = connection.escape_bytea(Marshal.dump({}))
          sql = "INSERT INTO #{namespace} (botname, marshal) VALUES ($1, $2);"
          connection.prepare('insert_statement', sql)

          connection.exec_prepared('insert_statement', [botname, str])
          {}
        else

          Marshal.load(connection.unescape_bytea(result.first['marshal']))
        end
      end

      def sync
        loop do
          wait
          save
        end
      end

      def wait
        sleep(interval)
      end

      def connection
        if @connection.nil?
          @connection = PG::connect(
            host:     host,
            user:     user,
            password: password,
            dbname:   dbname,
            port:     port
          )
          migrate(@connection)
        end
        @connection
      end

      def host
        ENV['POSTGRES_HOST'] || 'localhost'
      end

      def port
        ENV['POSTGRES_PORT'] || 5432
      end

      def user
        ENV['POSTGRES_USER'] || raise('ENV["POSTGRES_USER"] is required.')
      end

      def password
        ENV['POSTGRES_PASSWORD'] || raise('ENV["POSTGRES_PASSWORD"] is required.')
      end

      def dbname
        ENV['POSTGRES_DBNAME'] || raise('ENV["POSTGRES_DBNAME"] is required.')
      end

      def namespace
        ENV['POSTGRES_NAMESPACE'] || 'ruboty'
      end

      def botname
        ENV['POSTGRES_BOTNAME'] || 'ruboty'
      end

      def interval
        SAVE_INTERVAL
      end

      def migrate(conn)
        unless relation_exists?(conn)
          sql = "CREATE TABLE #{namespace} (botname VARCHAR(240) PRIMARY KEY, marshal BYTEA);"
          # conn.prepare('migrate_statement', sql)
          # conn.exec_prepared('migrate_statement', [namespace])
          conn.exec(sql)
          load
        end
      end

      def relation_exists?(conn)
        sql = "SELECT relname FROM pg_class WHERE relkind = 'r' AND relname = $1;"
        conn.prepare('exist_statement', sql)
        result = conn.exec_prepared('exist_statement', [namespace])
        return false if result.count == 0
        result.first['relname'] == namespace
      end

      def column_exists?(conn)
        sql = "SELECT * FROM #{namespace} WHERE botname = $1;"
      end
    end
  end
end
