require "test_helper"
require "api_test_module_extensions"
require "i18n_backend_test_helpers"

class PostgresJsonTestCase < ActiveSupport::TestCase
  using ApiTestModuleExtensions

  include I18nBackendTestHelpers

  def around(&block)
    I18n.enforce_available_locales = false
    I18n.available_locales = []
    I18n.locale = :en
    I18n.default_locale = :en
    I18n.load_path = []

    block.call

    I18n.enforce_available_locales = false
    I18n.available_locales = []
    I18n.locale = :en
    I18n.default_locale = :en
    I18n.load_path = []
    I18n.backend = nil
  end

  def translations
    raise NotImplementError("I18n::PostgresJson::TestCase.traslations")
  end

  def store_translations(locale, data)
    I18n.backend.store_translations(locale, data)
  end
end
