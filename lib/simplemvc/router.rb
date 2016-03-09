module Simplemvc
  class Router
    def initialize
      @routes = []
    end

    def match(url, *args)
      default = false

      if args.empty?
        target = nil
      else
        target = args.shift
        if target.is_a? Hash
          url += "/:action"
          default = "/#{target[:default][:action]}"
          target = nil
        end
      end

      url_parts = url.split("/")
      url_parts.select! { |part| !part.empty? }

      placeholders = []
      regexp = url_parts.map do |part|
        if part[0] == ":"
          placeholders << part[1..-1]
          "([A-Za-z0-9_]+)"
        else
          part
        end
      end

      regexp = regexp.join("/")

      @routes << {
        regexp: Regexp.new("^/#{regexp}$"),
        target: target,
        placeholders: placeholders,
        default: default
      }
    end

    def draw(&block)
      instance_eval(&block)
    end

    def check_url(url)
      @routes.each do |route|
        if route[:default]
          url = url.chomp("/")
          url += route[:default]
        end

        match = route[:regexp].match(url)
        next unless match
        placeholders = retrieve_placeholders(route, match)
        target = route[:target]
        target = retrieve_target(placeholders) if target.nil?

        return convert_target(target)
      end
    end

    def retrieve_placeholders(route, match)
      placeholders = {}
      route[:placeholders].each_with_index do |placeholder, index|
        placeholders[placeholder] = match.captures[index]
      end

      placeholders
    end

    def retrieve_target(placeholders)
      controller = placeholders["controller"]
      action = placeholders["action"]

      "#{controller}##{action}"
    end

    def convert_target(target)
      target_match = /^(?<controller_name>[^#]+)#(?<action_name>[^#]+)$/.
                     match(target)

      if target_match
        controller_name = target_match["controller_name"].to_camel_case
        controller = Object.const_get("#{controller_name}Controller")

        return controller.action(target_match["action_name"])
      end
    end
  end
end
