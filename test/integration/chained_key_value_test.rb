require "test_helper"
require "i18n_backend_test_helpers"
require "i18n/postgres_json/key_value/store"

class ChainedKeyValueTest < ActionDispatch::IntegrationTest
  include I18nBackendTestHelpers

  test "reads translations from the database" do
    with_fallbacks(:en, {
      application: {
        index: {
          title: "Hello, from YAML",
          not_declared_in_postgres: ""
        }
      }
    }) do
      I18n::PostgresJson::KeyValue::Translation.create!(
        translations: {
          "en.application.index.title": "Hello, from Postgres".to_json
        }
      )

      get root_path

      assert_select(
        %([data-i18n-key="application.index.title"]),
        text: "Hello, from Postgres"
      )
    end
  end

  test "can translate arrays" do
    with_fallbacks(:en, {
      application: {
        index: {
          title: "",
          not_declared_in_postgres: ""
        }
      }
    }) do
      post translations_path, params: {
        translation: {
          locale: :en,
          key: "application.index.array",
          value: ["zero", "one"]
        }
      }
      follow_redirect!

      assert_select(
        %([data-i18n-key="application.index.array[0]"]),
        text: "zero"
      )
      assert_select(
        %([data-i18n-key="application.index.array[1]"]),
        text: "one"
      )
    end
  end

  test "falls back when missing" do
    with_fallbacks(:en, {
      application: {
        index: {
          title: "",
          not_declared_in_postgres: "Hello, from YAML"
        }
      }
    }) do
      get root_path

      assert_select(
        %([data-i18n-key="application.index.not_declared_in_postgres"]),
        text: "Hello, from YAML"
      )
    end
  end

  def with_fallbacks(locale, translations, &block)
    simple_backend = I18n::Backend::Simple.new

    simple_backend.store_translations(locale, translations)

    chained_backend = I18n::Backend::Chain.new(
      I18n::Backend::KeyValue.new(I18n::PostgresJson::KeyValue::Store.new),
      simple_backend
    )

    with_backend(chained_backend, &block)
  end
end
