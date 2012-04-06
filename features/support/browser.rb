#!/usr/bin/env ruby

require "rspec/expectations"
require "selenium-webdriver"

$url = "http://localhost:8000"

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
	unless simple_url =~ /^#{Regexp.quote $url}(\/.*)$/
		raise "Not a local url: #{simple_url}"
	end
	return $1
end

STRING_RE = /"([^"]*)"/
ANY_RE = /(.+)/

I_HAVE = / (?: I\shave\s | I\sam\s | have\s | am\s | )?/x
I = / (?: I\s | )?/x

def driver

	# return if ready now

	return @the_driver if @the_driver

	# initialise long running driver

	unless $the_driver

		driver_type = (ENV["DRIVER_TYPE"] || "chrome").to_sym

		case driver_type

			when :chrome, :firefox
				$the_driver = Selenium::WebDriver.for driver_type

			when :html_unit
				$the_driver =
					Selenium::WebDriver.for(
						:remote,
						:url => "http://localhost:4444/wd/hub",
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
	the_driver.get "#{$url}/test/reset"
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

# given

Given /^#{I_HAVE}opened #{ANY_RE}$/ do |page|
	step "open #{page}"
end

Given /^#{I_HAVE}located the #{STRING_RE}/ do |name|
	@element = wait_for { find_element name }
end

Given /^#{I_HAVE}logged in$/ do
	step "log in via openid"
end

Given /^#{I_HAVE}created a workspace named #{STRING_RE}$/ do |name|
	step "create a workspace named \"#{name}\""
end

# when

When /^#{I}create a workspace named #{STRING_RE}$/ do |name|
	step "open the home page"
	step "enter \"#{name}\" in \"workspace name\""
	step "click the \"create workspace button\""
	wait_for { local_url =~ /^ \/workspace\/ [a-z]{16} $/x }
end

When /^#{I}open the page at #{STRING_RE}/ do |path|
	driver.get "#{$url}#{path}"
	wait_for_local_url path
end

When /^#{I}open the home page$/ do
	step "open the page at \"/\""
end

def next_id
	$next_id ||= 0
	ret = $next_id
	$next_id += 1
	return ret
end

When /^#{I}open a workspace$/ do
	step "create a workspace named \"Test workspace \""
end

When /^#{I}locate the #{STRING_RE}/ do |name|
	@element = wait_for { find_element name }
end

When /^#{I}click the #{STRING_RE}$/ do |name|
	button = wait_for { find_element name }
	button.click
end

When /^#{I}enter #{STRING_RE} in #{STRING_RE}$/ do |value, name|
	field = wait_for { find_element name }
	field.send_keys [ :control, "a" ]
	field.send_keys value
end

When /^#{I}fill in the following fields:$/ do |table|
	table.hashes.each do |hash|
		name = hash["name"]
		value = hash["value"]
		field = find_element name
		field.send_keys [ :control, "a" ]
		field.send_keys value
	end
end

DEFAULT_TIMEOUT = 1
DEFAULT_INTERVAL = 0.5

def wait_for_simple_url url_match, timeout = 1, interval = 0.5
	wait_for(timeout, interval) { url_match === simple_url }
end

def wait_for_local_url url_match, timeout = 1, interval = 0.5
	wait_for(timeout, interval) { url_match === local_url }
end

def wait_for timeout = 1, interval = 0.1

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

When /^#{I}log in via openid$/ do

	# begin login on our site

	step "open the home page"
	step "locate the \"login form\""
	step "fill in the following fields:",
		Cucumber::Ast::Table.new([
			[ "name", "value" ],
			[ "openid url", "http://localhost/~james/simpleid/identities/test.html" ]
		])
	step "click the \"ok button\""

	# first simpleid page

	wait_for { simple_url == "http://localhost/~james/simpleid/www/index.php" }

	field = driver.find_element :id, "edit-name"
	field.send_keys [ :control, "a" ]
	field.send_keys "test"

	field = driver.find_element :id, "edit-pass"
	field.send_keys [ :control, "a" ]
	field.send_keys "test"

	field = driver.find_element :id, "edit-submit"
	field.click

	# second simpleid page

	wait_for { simple_url == "http://localhost/~james/simpleid/www/index.php" }

	field = driver.find_element :id, "edit-submit"
	field.click

end

When /^#{I}log out$/ do
	button = wait_for { find_element "logout_button" }
	button.click
end

# then

Then /^the #{STRING_RE} should be displayed$/ do |name|
	@element = wait_for { find_element name }
end

Then /^#{I}should see a link titled #{STRING_RE}$/ do |title|
	@link = find_link title
end

When /^#{I}follow the link$/ do
	@link.click
end

Then /^it should have the following fields:$/ do |table|
	table.hashes.each do |hash|
		name = hash["name"]
		expect = hash["value"]
		field = find_element name
		actual = field.attribute("value")
		actual.should eq(expect)
	end
end

Then /^the location should be #{STRING_RE}$/ do |url|
	wait_for_local_url url
end

Then /^#{I}should be logged in$/ do
	wait_for { find_element "logged_in" }
end

Then /^#{I}should not be logged in$/ do
	wait_for { find_element "not_logged_in" }
end

Then /^#{I}should be on the home page$/ do
	step "the location should be \"/\""
end

Then /^#{I}should be on the workspace page for #{STRING_RE}$/ do |workspace_name|
	#local_url.should match(/^ \/ workspace \/ ([a-z]{16}) $/x)
	wait_for_local_url /^ \/ workspace \/ ([a-z]{16}) $/x
	driver.title.should eq("#{workspace_name} - Notes workspace")
end
