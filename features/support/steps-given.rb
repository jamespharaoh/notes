#!/usr/bin/env ruby

# Filename: features/support/steps-given.rb
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

Given /^#{I_HAVE}opened #{ANY_RE}$/ do |page|
	step "open #{page}"
end

Given /^#{I_HAVE}located the #{STRING_RE}/ do |name|
	step "locate the \"#{name}\""
end

Given /^#{I_HAVE}logged in$/ do
	step "log in via openid"
end

Given /^#{I_HAVE}created a workspace named #{STRING_RE}$/ do |name|
	step "create a workspace named \"#{name}\""
end
