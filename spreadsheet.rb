# frozen_string_literal: true

require 'bundler'
require 'csv'

Bundler.require

session = GoogleDrive::Session.from_service_account_key("client_secrets.json")

file = session.file_by_title("Congress")
file.export_as_file("congress.csv")

csv = 'congress.csv'
text = File.read(csv)
new = text.gsub('Young', 'REPLACED')
File.write(csv, new)

file.update_from_file('congress.csv')
