# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
                               key: '_scalarm_session' #,
                               #expire_after:  Rails.configuration.session_threshold.seconds

Rails.application.config.action_dispatch.cookies_serializer = :marshal
