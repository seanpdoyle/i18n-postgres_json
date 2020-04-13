module I18nBackendTestHelpers
  def with_backend(backend, &block)
    original_backend = I18n.backend
    I18n.backend = backend

    block.call(backend)

    I18n.backend = original_backend
  end
end
