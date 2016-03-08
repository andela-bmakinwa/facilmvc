module Simplemvc
  class Router
    def initialize
      @routes = []
    end

    def match(url, *args)
      target = args.shift unless args.empty?

      @routes << {
        regexp: Regexp.new("^#{url}$"),
        target: target
      }
    end

    def check_url(url)
      @routes.each do |route|
        match = route[:regexp].match(url)

        next unless match
        next unless route[:target] =~ /^([^#]+)#([^#]+)$/

        controller_name = $1.to_camel_case
        controller = Object.const_get("#{controller_name}Controller")

        return controller.action($2)
      end
    end
  end
end
