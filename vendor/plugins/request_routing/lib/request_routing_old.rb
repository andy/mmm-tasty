# This code is used to patch the old version of routing (as is included in 1.0 and 1.1).  See request_routing.rb
# For updates to the rewritten routing code.
module ActionController
  module Routing
    class RouteSet
      def recognize(request)
        @request = request
        
        string_path = @request.path  
        string_path.chomp! if string_path[0] == ?/  
        path = string_path.split '/'  
        path.shift  
   
        hash = recognize_path(path)  
        return recognition_failed(@request) unless hash && hash['controller']  
   
        controller = hash['controller']  
        hash['controller'] = controller.controller_path  
        @request.path_parameters = hash  
        controller.new 
      end
       alias :recognize! :recognize
    end
    
    class Route
      REQUEST_CONDITIONS = %w{subdomain domain method port remote_ip content_type accepts request_uri protocol}.map &:to_sym
      
      def initialize(path, options = {})
        @path, @options = path, options

        initialize_components path
        defaults, conditions, @request_conditions = initialize_hashes options.dup
        @defaults = defaults.dup
        configure_components(defaults, conditions)
        add_default_requirements
        initialize_keys
      end
      
      def initialize_hashes(options)
        path_keys = components.collect {|c| c.key }.compact 
        self.known = {}
        defaults = options.delete(:defaults) || {}
        conditions = options.delete(:require) || {}
        conditions.update(options.delete(:requirements) || {})
        request_conditions = options.delete(:conditions) || {}
    
        options.each do |k, v|
          if path_keys.include?(k) then (v.is_a?(Regexp) ? conditions : defaults)[k] = v
          else known[k] = v
          end
        end
        [defaults, conditions, request_conditions]
      end
  
      def write_recognition(generator = CodeGeneration::RecognitionGenerator.new)
        g = generator.dup
        g.share_locals_with generator
        g.before, g.current, g.after = [], components.first, (components[1..-1] || [])

        known.each do |key, value|
          if key == :controller then ControllerComponent.assign_controller(g, value)
          else g.constant_result(key, value)
          end
        end
        
        conds = @request_conditions.collect do |key, value|
          if value.is_a? Regexp
            "@request.#{ (key == :subdomain) ? "subdomains.first" : key.to_s }.to_s =~ #{value.inspect}"
          else
            "@request.#{ (key == :subdomain) ? "subdomains.first" : key.to_s } == #{value.inspect}"
          end
        end
        
        if !conds.empty?
          g.if(conds.join(' && ')) { |gp| gp.go }
        else
          g.go
        end

        generator
      end
      
    end
  end
end