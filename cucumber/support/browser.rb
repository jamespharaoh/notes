#!/usr/bin/env ruby

require "rspec/expectations"
require "selenium-webdriver"

$url = "http://localhost:8000"

def driver
	return $driver if $driver
	$driver = Selenium::WebDriver.for :firefox
	return $driver
end

When /^I open the home page$/ do
	driver.get "#{$url}/"
end

Then /^the "([^"]+)" should be displayed$/ do |id|
	$element = driver.find_element :class_name, wfid(id)
	$element.should_not be_nil
end

Then /^it should have the following fields:$/ do |table|
	table.hashes.each do |hash|
		name = hash["name"]
		expect = hash["value"]
		field = $element.find_element :class_name, wfid(name)
		field.should_not be_nil
		actual = field.attribute("value")
		actual.should eq(expect)
	end
end

def wfid name
	return "wfid_" + name.gsub(" ", "_")
end
