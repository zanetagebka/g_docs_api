# frozen_string_literal: true

require 'bundler'
require 'csv'
require 'fileutils'

Bundler.require

def google_session
  GoogleDrive::Session.from_config('script/config.json')
end

def take_file_name
  print "Enter file name by title: "
  @title = gets.chomp
  @file = google_session.file_by_name(@title)
end

def export_as(format)
  @file.export_as_file("files/#{@title}/#{@title}.#{format}")
end

def save_file_as
  FileUtils.mkdir_p "files/#{@title}"
  print "If you want to export Google Sheets please enter '1' otherwise leave empty\n"
  csv = gets.chomp
  (csv != '1') ? @format = 'txt' : @format = 'csv'
  export_as @format
end

def replace_text
  text = File.read("files/#{@title}/#{@title}.#{@format}")
  print "What text you want to replace: "
  to_replace = gets.chomp
  print "To what text you want to replace it: "
  replaced = gets.chomp
  @new_text = text.gsub(to_replace, replaced)
end

def save_new_file
  File.write("files/#{@title}/#{@title}.#{@format}", @new_text)
  @file.update_from_file("files/#{@title}/#{@title}.#{@format}")
end

google_session
take_file_name
save_file_as
replace_text
save_new_file
