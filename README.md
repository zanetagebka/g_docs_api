# g_docs_api
Small script allowing you to change document from Google Docs

Steps:

1. Go to: https://console.developers.google.com/apis/library
2. Create New Project
3. Allow APIs
- Google Drive API
- Google Sheets API
- Google Docs API

4. Go to: https://console.developers.google.com/apis/credentials
5. Click "Create credentials" -> "OAuth client ID".
6. Choose "Other" for "Application type".
7. Click "Create" and take note of the generated client ID and client secret.
8. copy and paste client_id and client_secrets to config.json file
9. Run in terminal command: `ruby script/spreadsheed.rb`
10. Follow the steps

NOTE: For filename you need to enter .csv for Sheets or .txt for Doc

Thanks

