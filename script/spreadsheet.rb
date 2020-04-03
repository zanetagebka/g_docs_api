require "google/apis/docs_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require 'bundler'
Bundler.require

OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Docs API Ruby Quickstart".freeze
CREDENTIALS_PATH = "script/credentials.json".freeze
TOKEN_PATH = "token.yaml".freeze
SCOPE = [Google::Apis::DocsV1::AUTH_DRIVE, Google::Apis::DriveV3::AUTH_DRIVE_FILE]

def authorize
  client_id = Google::Auth::ClientId.from_file CREDENTIALS_PATH
  token_store = Google::Auth::Stores::FileTokenStore.new file: TOKEN_PATH
  authorizer = Google::Auth::UserAuthorizer.new client_id, SCOPE, token_store
  user_id = "default"
  credentials = authorizer.get_credentials user_id
  if credentials.nil?
    url = authorizer.get_authorization_url base_url: OOB_URI
    puts "Open the following URL in the browser and enter the " \
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
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

print "Google document id:\n"

document_id = gets.chomp
service.get_document document_id

session = Google::Apis::DriveV3::DriveService.new
session.authorization = authorize

drive = Google::Apis::DriveV3::File.new

copied = session.copy_file(document_id)

# file = session.create_drive(copied.id, file_metadata)
# puts file.id

# drive = Google::Apis::DriveV3::File.new
# drive.authorization = authorize
#
# drive.metadata

print "replace text:\n"
to_replace = gets.chomp
print "replace to:\n"
replaced = gets.chomp
text1 = Google::Apis::DocsV1::SubstringMatchCriteria.new(text: "#{to_replace}")
req1 = Google::Apis::DocsV1::ReplaceAllTextRequest.new(contains_text: text1, replace_text: "#{replaced}")

replacement_requests = [Google::Apis::DocsV1::Request.new(replace_all_text: req1)]
batch_request = Google::Apis::DocsV1::BatchUpdateDocumentRequest.new(requests: replacement_requests)
service.batch_update_document(copied.id, batch_request)