module ApiTestModuleExtensions
  refine Module do
    require "mocha/setup"

    Module.include ActiveSupport::Testing::Declarative
  end
end
