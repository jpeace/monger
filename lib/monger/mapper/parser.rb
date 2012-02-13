module Monger
  module Mapper
    class Parser
      attr_reader :script

      def self.from_file(path, config)
        File.open(path, 'r') do |file|
          self.new(config, file.read)
        end
      end

      def initialize(config, script=nil)
        @config = config
        @script = transform(script) if !script.nil?
      end

      def transform(script=nil)
        script ||= @script

        transformed = ''
        script.each_line do |line|
          if line[/map :(\w+) do \|(\w+)\|/, 1]
            class_name = $~[1]
            block_param = $~[2]
            
            # Tranform symbol to class name
            separator = /_(\w)/
            class_name.scan(separator).count.times do
              pieces = class_name.partition(separator)
              class_name = pieces[0] + $~[1].upcase + pieces[2]
            end
            class_name[0] = class_name[0].upcase

            # Find class in configured modules
            found_in = nil
            @config.modules.each do |mod|
              begin
                sub = mod.const_get(class_name)
                found_in = mod
              rescue
                # Constant doesn't exist i.e. class is not in this module
              end
            end
            raise ScriptError if found_in.nil?
            transformed += "map #{found_in}::#{class_name} do |#{block_param}|\n"  
          else
            transformed += line
          end
        end
        transformed
      end
    end
  end
end