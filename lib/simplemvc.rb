require "simplemvc/version"
require "simplemvc/controller.rb"
require "simplemvc/utils.rb"
require "simplemvc/dependencies.rb"
require "simplemvc/router.rb"

module Simplemvc
  class Application
    def call(env)
      if env["PATH_INFO"] == "/favicon.ico"
        return [500, {}, []]
      end

      get_rack_app(env).call(env)
    end

    def routes
      @router ||= Simplemvc::Router.new
    end

    def get_rack_app(env)
      @router.check_url(env["PATH_INFO"])
    end
  end
end
