require 'net/https'
require 'JSON'

uri = URI('https://mindvalley.atlassian.net/rest/api/2/search?jql=project="PLAY"&maxResults=10')
saeed = ""
Net::HTTP.start(uri.host, uri.port,
                :use_ssl => uri.scheme == 'https',
:verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

  request = Net::HTTP::Get.new uri.request_uri
  request.basic_auth 'user', 'pass'

  response = http.request request # Net::HTTPResponse object

  saeed = JSON.parse(response.body)
end

puts "Total issues: #{saeed["total"]}"

saeed["issues"].each do |issue|
  puts "======================="
  url = "https://mindvalley.atlassian.net/rest/api/2/issue/#{issue["key"]}"
  uri1 = URI(url.strip)
  puts "#{issue["key"]} has the custom due date of: #{issue["fields"]["customfield_11100"]}"
  duedate= issue["fields"]["customfield_11100"]
  puts "due date is set to: #{duedate}"

  req = Net::HTTP::Put.new uri1.request_uri
  req.basic_auth 'user', 'pass'
  req['Content-Type'] = 'application/json'
  req.body = "{\"fields\":{\"duedate\":\"#{duedate}\"}}"
  puts req.body
  Net::HTTP.start(uri1.host, uri1.port,
                  :use_ssl => uri.scheme == 'https',
  :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
    response = http.request req

    puts response
    puts "======================="
  end

end