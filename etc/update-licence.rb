#!/usr/bin/env ruby

# Filename: etc/update-licence.rb
#
# Copyright 2012 James Pharaoh <james@phsys.co.uk>
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License

require "find"
require "pp"

LICENCE = <<END
% Filename: {FILENAME}
%
% Copyright 2012 James Pharaoh <james@phsys.co.uk>
%
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License
END

DELIM = {
	erlang: ?%,
	feature: ?#,
	make: ?#,
	ruby: ?#,
	css: " *",
}

PREFIX = {
	css: "/*",
}

SUFFIX = {
	css: " */",
}

SKIP_PATH = %W[
	Gemfile.lock
	LICENCE
	bundle
	data
	deps
	ebin
	notes.config
	rebar
	static/nitrogen
]

SKIP_EXT = %W[
	dump
	feature
	gif
	html
	log
]

def identify_extension path

	case path

		when /\.(app.src|erl|hrl)$/
			return :erlang

		when /\.feature$/
			return :feature

		when "notes.config.template"
			return :erlang

		when "rebar.config"
			return :erlang

		when "Gemfile"
			return :ruby

		when "Makefile"
			return :make

		when /\.less$/
			return :css

		when /\.html$/
			return :html

	end

	return :unknown
end

def identify_first_line path, line

	case line

		when /^#!\/usr\/bin\/env ruby$/
			return :ruby

		when /^#!/
			puts "Can't identify #{path} - #{line}"

		else
			puts "Can't identify #{path}"

	end

	return :unknown
end

Find.find "." do |path|

	next if path == "."
	path = path[2..-1]

	# skip certain directories and files

	if SKIP_PATH.include?(path) || path =~ /^\../
		Find.prune
		next
	end

	next if File.directory? path
	next if File.symlink? path

	if path =~ /\.([a-z]+)$/ && SKIP_EXT.include?($1)
		Find.prune
		next
	end

	# identify file by extension

	type = identify_extension path
	next if type == :skip

	# read file contents

	begin
		lines = File.read(path).split "\n"
	rescue
		puts "Error reading #{path}"
		next
	end

	# identify file by first line

	if type == :unknown
		type = identify_first_line path, lines.first
		next if type == :unknown
	end

	# look up the delimter

	delim = DELIM[type]
	raise "No delimiter for #{type}" unless delim
	delim_q = Regexp.quote delim
	prefix = PREFIX[type]
	suffix = SUFFIX[type]

	# skip past existing licence

	first_line = lines.first
	while lines.first
		line = lines.first
		if line == ""
			lines.shift
		elsif line == delim
			lines.shift
		elsif prefix && line == prefix
			lines.shift
		elsif suffix && line == suffix
			lines.shift
		elsif line =~ /^#!/
			lines.shift
		elsif line =~ /^#{delim_q} Filename: /
			lines.shift
		elsif line =~ /#{delim_q} Copyright/
			lines.shift
		elsif line =~ /#{delim_q}    /
			lines.shift
		else
			break
		end
	end

	# write out temp file with new licence

	File.open "#{path}.tmp", "w" do |f|
		if first_line =~ /#!/
			f.puts first_line
			f.puts
		end
		licence = LICENCE.clone
		licence.gsub! "{FILENAME}", path
		licence.gsub! /^%/, delim
		f.puts prefix if prefix
		f.puts licence
		f.puts suffix if suffix
		f.puts ""
		lines.each { |line| f.puts line }
	end

	# update original if temp file is different

	if File.read("#{path}.tmp") == File.read(path)
		File.unlink "#{path}.tmp"
	else
		puts "Updating #{path}"
		File.chmod File.stat(path).mode, "#{path}.tmp"
		File.rename "#{path}.tmp", path
		exit
	end

end
