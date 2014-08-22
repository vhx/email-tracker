require 'libraries'
require 'uri'


module SendgridTracker
  class App < Sinatra::Base
    use Rack::Logger
    set :app_file, __FILE__
    set :uri, ENV["METRICS_API_URL"] || "metrics-api.librato.com"

    helpers do
      def abort(status, type, msg)
        halt(status)
      end

      def bad_request!
        abort(400, :request, "Bad Request")
      end
    end

    post '/track' do
      logger.info "RECEIVED: #{request.body.read}"
      request.body.read.inspect
    end

    get '/' do
      status 200
      "ok"
    end

  end
end