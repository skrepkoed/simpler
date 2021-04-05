require_relative 'view'
module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      env['.simpler_params'].each{|k,v| @request.params[k]= v }
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def status(status)
      @response.status = status
    end

    def not_found
      status 404
      render plain:'Not Found'
    end

    def headers
      @response
    end

    def params
      @request.params
    end

    def render(template=nil, plain:nil)
      @request.env['simpler.template'] = template
      if plain
        headers = 'text/plain'
        @request.env['simpler.text'] = plain
      end
    end

  end
end
