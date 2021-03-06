#!/usr/bin/env ruby

# Filename: features/support/steps-then.rb
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
	wait_for { local_url == url }
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
	wait_for { local_url =~ /^ \/ workspace \/ ([a-z]{16}) $/x }
	wait_for { driver.title.should eq("#{workspace_name} - Notes workspace") }
end
