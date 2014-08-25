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
      # logger.info "RECEIVED: #{request.body.read}"
      sendgrid_reports = JSON.parse(request.body.read)
      queue = Librato::Metrics::Queue.new

      sendgrid_reports.each do |sendgrid_report|
        event_name = sendgrid_report['event'].gsub(/\s+/, "_").downcase
        queue.add "Sendgrid.#{event_name}" => { source: 'Sendgrid', measure_time: sendgrid_report['timestamp'], value: 1 }
      end

      Librato::Metrics.authenticate ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY']
      queue.submit

      request.body.read.inspect
    end

    get '/' do
      status 200
      "ok"
    end

    def authenticate_librato
      Librato::Metrics.authenticate ENV['LIBRATO_EMAIL'], ENV['LIBRATO_API_KEY']
      @authenticated = true
    end

    def log_delivery
      authenticate_librato unless @authenticated

    end


  end
end