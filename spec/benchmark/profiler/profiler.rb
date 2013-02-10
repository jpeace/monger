require 'ruby-prof'

module Benchmark

	class Profiler

		def before_each(&block)
			@before = Proc.new
		end

		def profile(name, options={}, &block)
			run_profile(name, RubyProf::CPU_TIME, options, &block)
			run_profile(name, RubyProf::PROCESS_TIME, options, &block)
			run_profile(name, RubyProf::MEMORY, options, &block)
			run_profile(name, RubyProf::WALL_TIME, options, &block)
		end

		def profile_cpu(name, options={}, &block)
			run_profile(name, RubyProf::CPU_TIME, options, &block)
		end

		def profile_process_time(name, options={}, &block)
			run_profile(name, RubyProf::PROCESS_TIME, options, &block)
		end

		def profile_memory(name, options={}, &block)
			run_profile(name, RubyProf::MEMORY, options, &block)
		end

		def profile_wall_time(name, options={}, &block)
			run_profile(name, RubyProf::WALL_TIME, options, &block)
		end

		private

		def run_profile(name, measure_mode, options, &block)
			puts "Running #{measure_names[measure_mode]} profile on #{name} #{options[:iterate] || 1} time(s)..."
			@before.call unless @before.nil?
			
			RubyProf.measure_mode = measure_mode
			if options[:iterate].nil?
				RubyProf.start
				yield
				result = RubyProf.stop
			else
				RubyProf.start
				options[:iterate].times { yield }
				result = RubyProf.stop
			end
		  printer = RubyProf::GraphHtmlPrinter.new(result)

			FileUtils.mkdir_p "#{File.dirname(__FILE__)}/results/#{name}"
			File.open("#{File.dirname(__FILE__)}/results/#{name}/#{measure_names[measure_mode]}_#{Time.now}.html", 'w') {|file| printer.print(file)}
		end

		def measure_names
			{ RubyProf::PROCESS_TIME => 'process_time', RubyProf::MEMORY => 'memory', RubyProf::CPU_TIME => 'cpu', RubyProf::WALL_TIME => 'wall_time' }
		end

	end
end