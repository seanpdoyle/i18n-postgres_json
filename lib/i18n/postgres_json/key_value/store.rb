module I18n
  module PostgresJson
    module KeyValue
      class Store
        def [](key)
          record[escape(key)]
        end

        def []=(key, value)
          record[escape(key)] = value
        end

        def keys
          record.keys
        end

        private

        def escape(key)
          key.gsub(
            I18n::Backend::Flatten::SEPARATOR_ESCAPE_CHAR,
            I18n.default_separator
          )
        end

        def record
          Translation.first_or_initialize
        end
      end
    end
  end
end
