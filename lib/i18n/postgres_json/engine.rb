module I18n
  module PostgresJson
    class Engine < ::Rails::Engine
      ActiveSupport.on_load(:active_record) do
        require "i18n/postgres_json/translation"
        require "i18n/postgres_json/key_value/translation"
      end
    end
  end
end
