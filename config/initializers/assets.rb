# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

url_from_config = Rails.application.secrets.base_url
url_from_config = (url_from_config || Utils.random_service_public_url('data_explorers') || '/')

Rails.configuration.action_controller.asset_host = url_from_config
