SIADEURL = if Rails.env.production?
             'https://api.apientreprise.fr'.freeze
           else
             'https://api-dev.apientreprise.fr'.freeze
           end
