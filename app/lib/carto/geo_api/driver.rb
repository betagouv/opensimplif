module Carto
  module GeoAPI
    class Driver
      class << self
        def regions
          call regions_url
        end

        def departements
          call departements_url
        end

        def pays
          File.open('app/lib/carto/geo_api/pays.json').read
        end

        def departements_url
          'https://geo.api.gouv.fr/departements'
        end

        def regions_url
          'https://geo.api.gouv.fr/regions'
        end

        private

        def call(api_url)
          RestClient.get api_url, params: {fields: :nom}
        rescue RestClient::ServiceUnavailable
          nil
        end
      end
    end
  end
end
