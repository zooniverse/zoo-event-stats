module Geo
  def self.locate(ip_address)
    return {} unless ip_address

    result = Geocoder.search(ip_address)

    if match = result[0]
      {
        country_name: match.country,
        country_code: match.country_code,
        city_name: match.city,
        coordinates: [match.longitude, match.latitude],
        latitude: match.latitude,
        longitude: match.longitude
      }
    else
      {}
    end
  rescue StandardError
    {}
  end
end
