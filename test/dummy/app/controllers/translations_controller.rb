class TranslationsController < ApplicationController
  def create
    I18n.backend.store_translations(
      translation_params.fetch(:locale),
      translation_params.fetch(:key) => translation_params.fetch(:value),
    )

    redirect_back fallback_location: root_url
  end

  private

  def translation_params
    params.require(:translation).permit(
      :key,
      :locale,
      :value,
      value: [],
    )
  end
end
