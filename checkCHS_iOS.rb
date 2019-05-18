require 'pathname'

filepath = Pathname.new(File.dirname(__FILE__)).realpath.to_s     

$outputfile = Pathname.new(File.dirname(__FILE__)).realpath.to_s + "/CHS_output"

File.open($outputfile, "w") do |f|
	f.puts "==========================="
end

def traverse(path)
	if File.directory?(path)
		dir = Dir.open(path)
		while name = dir.read
			next if name == "."
			next if name == ".."
			traverse(path + "/" + name)
		end
		dir.close
	else
		searchCHS(path)
	end
end

def searchCHS(path)
	if /\.m+$/ =~ path || /\.swift/ =~ path
		appfile = File.read(path)
		File.open($outputfile, "a") do |f|
			is_CHS = false
			appfile.each_line do |line|
				next if line.include?("NSLog")
				next if line.include?("print")
				#next if line.include?("//")
				line.gsub(/".*?"/) do |str|
					if /[\u4e00-\u9fa5]/ =~ str
						if !is_CHS
							is_CHS = true
							f.puts ""
							path.sub(/\/[^\/]*\.m+$/) do |name|
								f.puts name.slice!(1, name.length-1)
							end
							path.sub(/\/[^\/]*\.swift/) do |name|
								f.puts name.slice!(1, name.length-1)
							end	
							f.puts ""
							f.puts "path:" + path
							f.puts ""
						end
						if line.include?("//") 
							f.puts line
						else
							f.puts str
						end
					end
				end
			end
			if is_CHS
				f.puts ""
				f.puts "==========================="
			end
		end
	end
end

traverse(filepath)
