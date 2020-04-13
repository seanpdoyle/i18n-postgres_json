require "postgres_json_test_case"
require "i18n/postgres_json/backend"

module I18n
  module PostgresJson
    class Backend::ApiTest < PostgresJsonTestCase
      def around(&block)
        with_backend(I18n::PostgresJson::Backend.new) do
          super(&block)
        end
      end

      include I18n::Tests::Basics
      include I18n::Tests::Defaults
      include I18n::Tests::Interpolation
      # include I18n::Tests::Link
      include I18n::Tests::Lookup
      include I18n::Tests::Pluralization
      include I18n::Tests::Localization::Date
      include I18n::Tests::Localization::DateTime
      include I18n::Tests::Localization::Time

      test "make sure we use a PostgresJson backend" do
        assert_equal I18n::PostgresJson::Backend, I18n.backend.class
      end
    end
  end
end
