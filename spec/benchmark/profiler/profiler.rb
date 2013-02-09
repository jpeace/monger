require 'ruby-prof'

module Monger
	module Benchmark

		class Profiler

			def before_each(&block)
				@before = Proc.new
			end

			def profile(name, &block)
				run_profile(name, RubyProf::PROCESS_TIME, &block)
				run_profile(name, RubyProf::MEMORY, &block)
			end

			def profile_cpu(name, &block)
				run_profile(name, RubyProf::CPU_TIME, &block)
			end

			def profile_process_time(name, &block)
				run_profile(name, RubyProf::PROCESS_TIME, &block)
			end

			def profile_memory(name, &block)
				run_profile(name, RubyProf::MEMORY, &block)
			end

			def profile_wall_time(name, &block)
				run_profile(name, RubyProf::WALL_TIME, &block)
			end

			private

			def measurement_names
				{ RubyProf::PROCESS_TIME => 'processor', RubyProf::MEMORY => 'memory' }
			end

			def run_profile(name, measure_mode, &block)
				@before.call
				
				RubyProf.measure_mode = measure_mode
				RubyProf.start
				yield
				result = RubyProf.stop
			  printer = RubyProf::GraphHtmlPrinter.new(result)

				FileUtils.mkdir_p "#{File.dirname(__FILE__)}/results/#{name}"
				File.open("#{File.dirname(__FILE__)}/results/#{name}/#{measurement_names[measure_mode]}_#{Time.now}.html", 'w') {|file| printer.print(file)}
			end

		end
	end
end