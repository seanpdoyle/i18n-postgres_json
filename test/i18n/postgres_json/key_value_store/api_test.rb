require "postgres_json_test_case"
require "i18n/postgres_json/key_value/store"

module I18n
  module PostgresJson
    module KeyValue
      class StoreApiTest < PostgresJsonTestCase
        def around(&block)
          key_value_backend = I18n::Backend::KeyValue.new(
            I18n::PostgresJson::KeyValue::Store.new
          )

          with_backend(key_value_backend) do
            super(&block)
          end
        end

        def store_translations(locale, data)
          I18n.backend.store_translations(locale, data)
        end

        include I18n::Tests::Basics
        include I18n::Tests::Defaults
        include I18n::Tests::Interpolation
        include I18n::Tests::Link
        include I18n::Tests::Lookup
        include I18n::Tests::Pluralization
        include I18n::Tests::Localization::Date
        include I18n::Tests::Localization::DateTime
        include I18n::Tests::Localization::Time

        test "make sure we use a PostgresJson::KeyValue::Store backend" do
          assert_equal I18n::Backend::KeyValue, I18n.backend.class
          assert_equal I18n::PostgresJson::KeyValue::Store, I18n.backend.store.class
        end
      end
    end
  end
end
