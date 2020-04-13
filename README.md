# I18n::PostgresJson

Internationalization backed by Postgres JSON columns

## Usage

[PostgreSQL's][pg] support for storing objects as [JSON and JSONB
columns][pg-json], integrated with [`ActiveRecord` column-aware
models][activerecord-pg-json] makes it an ideal candidate to store dynamic,
editable application translation text.

This gem's inspiration comes from the [Rails Internationalization (<abbr
title="Internationalization">i18n</abbr>) Guides][i18n-guides] mention of
[`i18n-active_record`][i18n-ar].

[Cascading translations][i18n-chain] by combining a dynamic, database driven
translation source ahead of the default `I18n::Backend::Simple` enable dynamic
copy editing, with an in-code foundational source.

[pg]: https://www.postgresql.org/about/
[pg-json]: https://www.postgresql.org/docs/9.4/datatype-json.html#DATATYPE-JSON
[activerecord-pg-json]: https://guides.rubyonrails.org/active_record_postgresql.html#json-and-json
[i18n-ar]: https://github.com/svenfuchs/i18n-active_record
[i18n-guides]: https://guides.rubyonrails.org/i18n.html#using-different-backends
[i18n-chain]: https://www.rubydoc.info/github/ruby-i18n/i18n/master/I18n/Backend/Chain

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'i18n-postgres_json'
```

And then execute:

```bash
bundle
```

### I18n::PostgresJson::KeyValue::Store

The `I18n::PostgresJson::KeyValue::Store` class serves as a `store` for the
[`I18n::Backend::KeyValue` backend][i18n-key-value].

The `I18n::PostgresJson::KeyValue::Store` interacts with a Postgres table
consisting of:

```
                                         Table "public.i18n_postgres_json_key_value_store_translations"
    Column    |            Type             | Collation | Nullable |                                   Default
--------------+-----------------------------+-----------+----------+-----------------------------------------------------------------------------
 id           | integer                     |           | not null | nextval('i18n_postgres_json_key_value_store_translations_id_seq'::regclass)
 translations | json                        |           | not null | '{}'::json
 created_at   | timestamp without time zone |           | not null |
 updated_at   | timestamp without time zone |           | not null |
Indexes:
    "i18n_postgres_json_key_value_store_translations_pkey" PRIMARY KEY, btree (id)
```

This style of backend store _all_ translations, regardless of locale, within the
same `translations` column, backed by [JSON][pg-json].

**This table is only ever intended to store a single row.**

To generate this table, install the necessary migrations:

```bash
rails i18n_postgres_json:install:key_value
```

Then execute them:

```bash
rails db:migrate
```

Next, configure your `I18n.backend` (either in a Rails environment configuration
block, or an initializer of its own):

```ruby
# config/initializers/i18n.rb
I18n.backend = I18n::Backend::Chain.new(
  I18n::Backend::KeyValue.new(I18n::PostgresJson::KeyValue::Store.new),
  I18n.backend, # typically defaults to I18n::Backend::Simple
)
```

**Caveat:** It's worth noting that according to the [`I18n::Backend::KeyValue`
documentation][i18n-key-value], this backend cannot store serialized [Ruby
`Proc` instances][proc]:

> Since these stores only supports string, all values are converted to JSON
> before being stored, allowing it to also store booleans, hashes and arrays.
> **However, this store does not support Procs.**

[i18n-key-value]: https://www.rubydoc.info/github/ruby-i18n/i18n/master/I18n/Backend/KeyValue
[proc]: https://ruby-doc.org/core-2.7.1/Proc.html

### I18n::PostgresJson::Backend

The `I18n::PostgresJson::Backend` class serves as an `I18n::Backend`
implementation of its own.

The `I18n::PostgresJson::Backend` interacts with a Postgres table
consisting of:

```
                                         Table "public.i18n_postgres_json_backend_translations"
    Column    |            Type             | Collation | Nullable |                               Default
--------------+-----------------------------+-----------+----------+---------------------------------------------------------------------
 id           | integer                     |           | not null | nextval('i18n_postgres_json_backend_translations_id_seq'::regclass)
 locale       | character varying           |           | not null |
 translations | json                        |           | not null | '{}'::json
 created_at   | timestamp without time zone |           | not null |
 updated_at   | timestamp without time zone |           | not null |
Indexes:
    "i18n_postgres_json_backend_translations_pkey" PRIMARY KEY, btree (id)
    "index_i18n_postgres_json_backend_translations_on_locale" UNIQUE, btree (locale)
```

This style of backend splits each `locale` into its own row, separating out
translations into one lookup table per-locale. The `translations` column is
backed by [JSON][pg-json].

To generate this table, install the necessary migrations:

```bash
rails i18n_postgres_json:install:backend
```

Then execute them:

```bash
rails db:migrate
```

Next, configure your `I18n.backend` (either in a Rails environment configuration
block, or an initializer of its own):

```ruby
# config/initializers/i18n.rb
I18n.backend = I18n::Backend::Chain.new(
  I18n::PostgresJson::Backend.new,
  I18n.backend, # typically defaults to I18n::Backend::Simple
)
```

**Caveat**: It's worth noting that the `I18n::PostgresJson::Backend` does not
currently support translation linking.

### Writing to the tables

Regardless of whether your application integrates with
`I18n::PostgresJson::KeyValue::Store`, or `I18n::PostgresJson::Backend`, the
implementation for updating existing translations will be the same: use
[`I18n::Backend::Base.store_translations`][store_translations].

If you were to edit a translation through an HTML `<form>` element that
submitted to a Rails controller, it might look something like this:

```html
<!-- app/views/posts/index.html.erb -->
<form action="/translations" method="post">
  <input type="hidden" name="translation[locale]" value="en">
  <input type="hidden" name="translation[key]" value="posts.index.title">

  <label for="translation_value">
    Translation for posts.index.title
  </label>
  <input type="text" id="translation_value" name="translation[value]">

  <button>
    Save Translation
  </button>
</form>
```

When that `<form>` element is submitted, the resulting controller action (in
this example, `translations#create`) would pass along the submitted translation
to `store_translations`:

```ruby
class TranslationsController < ApplicationController
  def create
    I18n.backend.store_translation(
      translation_params.fetch(:locale),
      translation_params.fetch(:key) => translation_params.fetch(:value),
    )

    redirect_to posts_url
  end

  private

  def translation_params
    params.require(:translation).permit(
      :key,
      :locale,
      :value,
    )
  end
end
```

**Caveat:** This is a potentially disruptive (and destructive!) action, so the
application would want to limit control to authenticated content editors. This
example omits those details for the sake of brevity.

[store_translations]: https://www.rubydoc.info/github/ruby-i18n/i18n/I18n/Backend/Base#store_translations-instance_method

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
