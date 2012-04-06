#!/usr/bin/env ruby

require "rspec/expectations"
require "selenium-webdriver"

$url = "http://localhost:8000"

def wfid name
	return "wfid_" + name.gsub(" ", "_")
end

def simple_url
	url = driver.current_url
	url = url[0...url.index("?")] unless url.index("?") == nil
	return url
end

STRING_RE = /"([^"]*)"/

I_HAVE = / (?: I\shave\s | I\sam\s | have\s | am\s | )?/x

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

# given

Given /^#{I_HAVE}opened the home page$/ do
	driver.get "#{$url}/"
end

Given /^#{I_HAVE}located the #{STRING_RE}/ do |id|
	@element = driver.find_element :class_name, wfid(id)
	@element.should_not be_nil
end

Given /^#{I_HAVE}logged in$/ do
	step "log in via openid"
end

# when

When /^(?:I )?open the home page$/ do
	driver.get "#{$url}/"
end

Given /^(?:I )?locate the #{STRING_RE}/ do |id|
	@element = driver.find_element :class_name, wfid(id)
	@element.should_not be_nil
end

def find_element name

	# search under our context element first

	begin
		if @element
			elements = @element.find_elements :class_name, wfid(name)
			raise "Multiple matches" if elements.size > 1
			return elements[0] unless elements.empty?
		end
	rescue Selenium::WebDriver::Error::StaleElementReferenceError
		@element = nil
	end

	# then try a page wide search

	elements = driver.find_elements :class_name, wfid(name)
	raise "Multiple matches" if elements.size > 1
	return elements[0] unless elements.empty?

	# raise an error

	raise "Can't find element: #{name}"
end

When /^(?:I )?click the #{STRING_RE}$/ do |name|
	button = find_element name
	button.click
end

When /^(?:I )?fill in the following fields:$/ do |table|
	table.hashes.each do |hash|
		name = hash["name"]
		value = hash["value"]
		field = @element.find_element :class_name, wfid(name)
		field.should_not be_nil
		field.send_keys [ :control, "a" ]
		field.send_keys value
	end
end

When /^(?:I )?log in via openid$/ do

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

When /^I log out$/ do
	button = driver.find_element :class, "logout_button"
	button.click
end

# then

Then /^the #{STRING_RE} should be displayed$/ do |name|
	@element = driver.find_element :class_name, wfid(name)
	@element.should_not be_nil
end

Then /^it should have the following fields:$/ do |table|
	table.hashes.each do |hash|
		name = hash["name"]
		expect = hash["value"]
		field = @element.find_element :class_name, wfid(name)
		field.should_not be_nil
		actual = field.attribute("value")
		actual.should eq(expect)
	end
end

Then /^the location should be #{STRING_RE}$/ do |url|
	url = "#{$url}#{url}" if url[0] == "/"
	simple_url.should eq url
end

Then /^I should be logged in$/ do
	body = driver.find_element :class, "logged_in"
	body.should_not be_nil
end

Then /^I should not be logged in$/ do
	body = driver.find_element :class, "not_logged_in"
	body.should_not be_nil
end

Then /^I should be on the home page$/ do
	step "the location should be \"/\""
end
