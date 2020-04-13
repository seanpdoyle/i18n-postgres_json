module I18n
  module PostgresJson
    module KeyValue
      class Translation < ActiveRecord::Base
        self.table_name = "i18n_postgres_json_key_value_store_translations"

        def [](key)
          translations[key]
        end

        def []=(key, value)
          translations[key] = value

          save!
        end

        def keys
          translations.keys
        end
      end
    end
  end
end
