module Runtime
	Dir.glob(File.join(File.dirname(__FILE__), 'values/*.rb')).each { |f| require f }
end