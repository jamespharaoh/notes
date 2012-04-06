#!/usr/bin/env ruby

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
