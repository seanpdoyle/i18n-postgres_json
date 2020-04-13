module I18n
  module PostgresJson
    class Backend
      include I18n::Backend::Base

      def available_locales=(available_locales)
        @available_locales = Array(available_locales).map(&:to_sym).presence
      end

      def available_locales
        @available_locales || Translation.available_locales
      end

      def store_translations(locale, data, **options)
        Translation.store_translations(locale, data)
      end

      protected

      def lookup(locale, key, scope = [], separator: I18n.default_separator, **options)
        Translation.locale(locale).lookup(key, scope, separator: separator)
      end
    end
  end
end
