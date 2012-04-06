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
	unless simple_url =~ /^#{Regexp.quote $url}(\/.+)$/
		raise "Not a local url"
	end
	return $1
end

STRING_RE = /"([^"]*)"/

I_HAVE = / (?: I\shave\s | I\sam\s | have\s | am\s | )?/x
I = / (?: I\s | )?/x

def driver

	# return if ready now
	return @the_driver if @the_driver

	# initialise long running driver
	unless $the_driver
		$the_driver = Selenium::WebDriver.for :firefox
		at_exit do
			@the_driver.close
		end
	end
	the_driver = $the_driver

	# clear state
	the_driver.manage.delete_all_cookies
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

	raise "Can't find element: #{name}"
end

# given

Given /^#{I_HAVE}opened the home page$/ do
	driver.get "#{$url}/"
end

Given /^#{I_HAVE}located the #{STRING_RE}/ do |name|
	@element = find_element name
end

Given /^#{I_HAVE}logged in$/ do
	step "log in via openid"
end

# when

When /^#{I}open the home page$/ do
	driver.get "#{$url}/"
end

Given /^#{I}locate the #{STRING_RE}/ do |name|
	@element = find_element name
end

When /^#{I}click the #{STRING_RE}$/ do |name|
	button = find_element name
	button.click
end

When /^I enter #{STRING_RE} in #{STRING_RE}$/ do |value, name|
	field = find_element name
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

When /^#{I}log in via openid$/ do

	step "open the home page"
	step "locate the \"login form\""
	step "fill in the following fields:",
		Cucumber::Ast::Table.new([
			[ "name", "value" ],
			[ "openid url", "http://localhost/~james/simpleid/identities/test.html" ]
		])
	step "click the \"ok button\""

	# first page

	# enter username
	field = driver.find_element :id, "edit-name"
	field.send_keys [ :control, "a" ]
	field.send_keys "test"

	# enter password
	field = driver.find_element :id, "edit-pass"
	field.send_keys [ :control, "a" ]
	field.send_keys "test"

	# click ok
	field = driver.find_element :id, "edit-submit"
	field.click

	# second page

	# click ok
	field = driver.find_element :id, "edit-submit"
	field.click

end

When /^#{I}log out$/ do
	button = find_element "logout_button"
	button.click
end

# then

Then /^the #{STRING_RE} should be displayed$/ do |name|
	@element = find_element name
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
	url = "#{$url}#{url}" if url[0] == "/"
	simple_url.should eq url
end

Then /^I should be logged in$/ do
	find_element "logged_in"
end

Then /^I should not be logged in$/ do
	find_element "not_logged_in"
end

Then /^I should be on the home page$/ do
	step "the location should be \"/\""
end

Then /^I should be on the workspace page for #{STRING_RE}$/ do |workspace_name|
	local_url.should match(/^ \/ workspace \/ ([a-z]{16}) $/x)
	# TODO check name!
end
