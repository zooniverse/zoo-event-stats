# frozen_string_literal: true

# Copied from https://github.com/lostisland/faraday_middleware/blob/af198df882c00b0c2e63a8f1cdae4b1db8cac194/lib/faraday_middleware/response/caching.rb
# modified to include the request body of elastic search GET queries
# Wat! - ES uses GET request bodies to specify the query!
#      - I am not alone thinking that is bad practice:
#      - https://stackoverflow.com/questions/36939748/elasticsearch-get-request-with-request-body
#
# Anyway, we live and learn, let's fix this :)

require 'faraday_middleware'

module Stats
  module Es
    class RequestCache < FaradayMiddleware::Caching
      def cache_key(env)
        digest = super(env)
        digest_with_req_body = "#{digest}#{env.body}"
        Digest::SHA1.hexdigest(digest_with_req_body)
      end
    end
  end
end