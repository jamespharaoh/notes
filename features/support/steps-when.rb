#!/usr/bin/env ruby

# Filename: features/support/steps-when.rb
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

When /^#{I}create a workspace named #{STRING_RE}$/ do |name|
	step "open the home page"
	step "enter \"#{name}\" in \"workspace name\""
	step "click the \"create workspace button\""
	wait_for { local_url =~ /^ \/workspace\/ [a-z]{16} $/x }
end

When /^#{I}open the home page$/ do
	step "open the page at \"/\""
end

When /^#{I}open a workspace$/ do
	step "create a workspace named \"Test workspace \""
end

When /^#{I}open the page at #{STRING_RE}/ do |path|
	driver.get "#{TARGET_URL}#{path}"
	wait_for { local_url == path }
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
