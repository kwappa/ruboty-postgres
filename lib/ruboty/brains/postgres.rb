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
        sql = 'UPDATE $1 SET marshal = $2 WHERE botname = $3;'
        connection.prepare('save_statement', sql)
        connection.exec_prepared('save_statement', [namespace, Marshal.dump(data), botname])
      end

      def load
        sql = 'SELECT marshal FROM $1 WHERE botname = $2;'
        connection.prepare('load_statement', sql)
        str = connection.exec_prepared('load_statement', [namespace, botname])
        Marshal.load(str)
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
        @connection ||= PG::connect(
          host:     host,
          user:     user,
          password: password,
          dbname:   dbname,
          port:     port
        )
      end

      def host
        ENV['POSTGRES_HOST'] || 'localhost'
      end

      def port
        ENV['POSTGRES_PORT'] || 5432
      end

      def user
        ENV['POSTGRES_USER'] || raise 'ENV["POSTGRES_USER"] is required.'
      end

      def password
        ENV['POSTGRES_PASSWORD'] || raise 'ENV["POSTGRES_PASSWORD"] is required.'
      end

      def dbname
        ENV['POSTGRES_DBNAME'] || raise 'ENV["POSTGRES_DBNAME"] is required.'
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
    end
  end
end
