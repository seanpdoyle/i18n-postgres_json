$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "i18n/postgres_json/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "i18n-postgres_json"
  spec.version     = I18n::PostgresJson::VERSION
  spec.authors     = ["Sean Doyle"]
  spec.email       = ["sean.p.doyle24@gmail.com"]
  spec.homepage    = "https://github.com/seanpdoyle/i18n-postgres_json"
  spec.summary     = "Internationalization backed by Postgres JSON columns"
  spec.description = "Store I18n values in PostgreSQL JSON columns"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "activerecord", ">= 4.2.0"
  spec.add_dependency "pg"

  spec.add_development_dependency "mocha", "~> 1.7.0"
  spec.add_development_dependency "minitest-around", "~> 0.5.0"
end
