# frozen_string_literal: true

require 'bundler'
require 'csv'

Bundler.require

def google_session
  GoogleDrive::Session.from_config('script/config.json')
end

def take_file_name
  print "Enter file name by title: "
  title = gets.chomp
  @file = google_session.file_by_title(title)
end

def save_file_as
  print "Enter file name to save as: "
  @save_as = gets.chomp
  @file.export_as_file("files/#{@save_as}")
end

def replace_text
  text = File.read("files/#{@save_as}")
  print "What text you want to replace: "
  to_replace = gets.chomp
  print "To what text you want to replace it: "
  replaced = gets.chomp
  @new_text = text.gsub(to_replace, replaced)
end

def save_new_file
  File.write("files/#{@save_as}", @new_text)

  @file.update_from_file("files/#{@save_as}")
end

google_session
take_file_name
save_file_as
replace_text
save_new_file
