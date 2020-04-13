class CreateI18nPostgresJsonKeyValueStoreTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :i18n_postgres_json_key_value_store_translations do |t|
      t.json :translations, null: false, default: {}

      t.timestamps null: false
    end
  end
end
