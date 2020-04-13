namespace :i18n_postgres_json do
  namespace :install do
    Rake::Task["i18n_postgres_json_engine:install:migrations"].clear_comments

    desc "Copy over the migrations needed for I18n::PostgresJson::Backend integration"
    task backend: :environment do
      ENV["MIGRATIONS_PATH"] = "db/migrate/backend"

      if Rake::Task.task_defined?("i18n_postgres_json_engine:install:migrations")
        Rake::Task["i18n_postgres_json_engine:install:migrations"].invoke
      else
        Rake::Task["app:i18n_postgres_json_engine:install:migrations"].invoke
      end
    end

    desc "Copy over the migrations needed for I18n::PostgresJson::KeyValue::Store integration"
    task key_value: :environment do
      ENV["MIGRATIONS_PATH"] = "db/migrate/key_value"

      if Rake::Task.task_defined?("i18n_postgres_json_engine:install:migrations")
        Rake::Task["i18n_postgres_json_engine:install:migrations"].invoke
      else
        Rake::Task["app:i18n_postgres_json_engine:install:migrations"].invoke
      end
    end
  end
end
