module I18n
  module PostgresJson
    class Translation < ActiveRecord::Base
      self.table_name = "i18n_postgres_json_backend_translations"

      def self.available_locales
        (
          distinct.order(locale: :asc).pluck(:locale) + [I18n.default_locale]
        ).map(&:to_sym).uniq
      end

      def self.store_translations(locale, data)
        record = self.locale(locale)

        record.translations.deep_merge!(data.deep_stringify_keys)

        record.save!
      end

      def self.locale(locale)
        find_or_initialize_by(locale: locale)
      end

      def dig(*keys)
        keys = Array(keys)

        translations.with_indifferent_access.dig(*keys)
      end

      def lookup(key, scope = [], separator:)
        _, *keys = I18n.normalize_keys(locale, key, scope, separator)

        translated = keys.each_with_index.reduce(nil) { |translation, (_, index)|
          if translation.present?
            translation
          else
            leading = keys.take(index)
            trailing = keys.drop(index)

            dig(*([leading.join(separator)] + keys - leading)) ||
              dig(*(keys - trailing + [trailing.join(separator)]))
          end
        }

        if translated.respond_to?(:deep_symbolize_keys)
          translated.deep_symbolize_keys
        else
          translated
        end
      end
    end
  end
end
