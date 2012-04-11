#!/usr/bin/env ruby

# Filename: features/support/browser.rb
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

require "rspec/expectations"
require "selenium-webdriver"

DEFAULT_TIMEOUT = 5
DEFAULT_INTERVAL = 0.5

def usid name
	return name.gsub(" ", "_")
end

def wfid name
	return "wfid_" + name.gsub(" ", "_")
end

def simple_url
	url = driver.current_url
	url = url[0...url.index("?")] unless url.index("?") == nil
	return url
end

def local_url
	notes_url_quoted = Regexp.quote CONFIG["general"]["notes_url"]
	unless simple_url =~ /^#{notes_url_quoted}(\/.*)$/
		raise "Not a local url: #{simple_url}"
	end
	return $1
end

def wait_for timeout = DEFAULT_TIMEOUT, interval = DEFAULT_INTERVAL

	timeout_at = Time.now.to_f + timeout

	while true

		# check for success

		ret = yield
		return ret if ret

		# check for timeout

		if timeout_at < Time.now.to_f
			raise "Timed out"
		end

		# sleep

		sleep interval
	end
end

def next_id
	$next_id ||= 0
	ret = $next_id
	$next_id += 1
	return ret
end

def driver

	# return if ready now

	return @the_driver if @the_driver

	# initialise long running driver

	unless $the_driver

		driver_type = CONFIG["selenium"]["driver"].to_sym

		case driver_type

			when :chrome, :firefox
				$the_driver = Selenium::WebDriver.for driver_type

			when :html_unit
				$the_driver =
					Selenium::WebDriver.for(
						:remote,
						:url => CONFIG["selenium"]["server_url"],
						:desired_capabilities =>
							Selenium::WebDriver::Remote::Capabilities.htmlunit(
								:javascript_enabled => true))

			else
				raise "Invalid driver type #{driver_type}"

		end

		at_exit do
			$the_driver.close
		end

	end
	the_driver = $the_driver

	# clear state

	the_driver.manage.delete_all_cookies
	the_driver.get "#{CONFIG["general"]["notes_url"]}/test/reset"
	the_driver.get "about:blank"

	# and return

	return @the_driver = the_driver
end

def find_element name

	# search under our context element first

	begin
		if @element

			elements = @element.find_elements(:class_name, wfid(name)) \
				+ @element.find_elements(:class_name, usid(name))
			raise "Multiple matches for #{name}" if elements.size > 1
			return elements[0] unless elements.empty?

		end
	rescue Selenium::WebDriver::Error::StaleElementReferenceError
		@element = nil
	end

	# then try a page wide search

	elements = driver.find_elements(:class_name, wfid(name)) \
		+ driver.find_elements(:class_name, usid(name))
	raise "Multiple matches for #{name}" if elements.size > 1
	return elements[0] unless elements.empty?

	# raise an error

	return nil
end

def find_link title

	# search for link with that name

	elements = driver.find_elements :link_text, title
	raise "Multiple matches for #{title}" if elements.size > 1
	return elements[0] unless elements.empty?

	# raise an error

	raise "Can't find link: #{title}"

end
