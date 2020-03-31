# frozen_string_literal: true

require 'bundler'
require 'csv'

Bundler.require

session = GoogleDrive::Session.from_service_account_key("client_secrets.json")

print "Enter file name by title: "
title = gets.chomp
file = session.file_by_title(title)
print "Enter file name to save as: "
save_as = gets.chomp
file.export_as_file(save_as)

csv = save_as
text = File.read(csv)
new = text.gsub('Young', 'REPLACED')
File.write(csv, new)

file.update_from_file(save_as)
