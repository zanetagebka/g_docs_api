# frozen_string_literal: true

require 'google/apis/docs_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'bundler'
Bundler.require

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Docs API Ruby Quickstart'
CREDENTIALS_PATH = 'script/credentials.json'
TOKEN_PATH = 'token.yaml'
SCOPE = [Google::Apis::DocsV1::AUTH_DRIVE, Google::Apis::DriveV3::AUTH_DRIVE_FILE]

def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = 'default'
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id,
        code: code,
        base_url: OOB_URI
    )
  end
  credentials
end

service = Google::Apis::DocsV1::DocsService.new
service.authorization = authorize

session = Google::Apis::DriveV3::DriveService.new
session.authorization = authorize

drive = Google::Apis::DriveV3::File.new

### Main Script Part
print "Enter Your Google document id:\n"
document_id = gets.chomp
file = session.get_file(document_id)
copied_file = session.copy_file(file.id)

###CREATION OF FOLDER
drive.name = copied_file.name.delete_prefix("Copy of ")
drive.mime_type = "application/vnd.google-apps.folder"
folder = session.create_file(drive, fields: 'id')

###UPDATE OF COPIED FILE
new_file = session.update_file(copied_file.id, add_parents: folder.id, fields: 'id, parents')

###UPDATE OF TEXT FROM DOC
print "What text you want to replace:\n"
to_replace = gets.chomp
print "What you want to enter instead:\n"
replaced = gets.chomp

text = Google::Apis::DocsV1::SubstringMatchCriteria.new(text: to_replace.to_s)
request = Google::Apis::DocsV1::ReplaceAllTextRequest.new(contains_text: text, replace_text: replaced.to_s)
replacement_requests = [Google::Apis::DocsV1::Request.new(replace_all_text: request)]
batch_request = Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: replacement_requests)
service.batch_update_document(new_file.id, batch_request)
