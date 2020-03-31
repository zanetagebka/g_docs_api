# frozen_string_literal: true

require 'bundler'
require 'csv'

Bundler.require

print "Enter secrets for GoogleDrive session: "
secrets_file = gets.chomp
session = GoogleDrive::Session.from_service_account_key("#{secrets_file}")

print "Enter file name by title: "
title = gets.chomp
file = session.file_by_title(title)
print "Enter file name to save as: "
save_as = gets.chomp
file.export_as_file(save_as)

csv = save_as
text = File.read(csv)
print "What text you want to replace: "
to_replace = gets.chomp
print "To what text you want to replace it: "
replaced = gets.chomp
new = text.gsub(to_replace, replaced)
File.write(csv, new)

file.update_from_file(save_as)
