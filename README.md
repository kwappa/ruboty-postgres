# Ruboty::Postgres

store memory of [ruboty](https://github.com/r7kamura/ruboty) in postgresql

## ENV

- `POSTGRES_HOST`
    - host of postgres (default: localhost)
    - optional
- `POSTGRES_PORT`
    - port number of postgres (default: 5432)
    - optional
- `POSTGRES_USER`
    - user name of postgres
    - required
- `POSTGRES_PASSWORD`
    - password of postgres
    - required
- `POSTGRES_DBNAME`
    - database name of postgres
    - required
- `POSTGRES_NAMESPACE`
    - relation name of postgres (default: ruboty)
    - optional
- `POSTGRES_BOTNAME`
    - name of your ruboty (default: ruboty)
    - optional
    - max length: 240
- `POSTGRES_SAVE_INTERVAL`
    - sleep duration between each save (default: 10)
    - optional

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
