
require 'uri'
require "olympus-camera/version"
require "olympus-camera/any"
require "olympus-camera/commands_parser"

# for debug
require 'pp'
require 'pry'


class OlympusCamera
  DEFAULT_HEADERS = {
      "Connection" => 'close',
      "User-Agent" =>  'OlympusCameraKit',
  }

  attr_accessor :api_host
  attr_reader :commands, :api_version, :support_funcs

  def initialize(commandlist_xml: nil, api_host: "http://192.168.0.10")
    self.api_host = api_host
    parsed_commands = CommandsParser.parse(commandlist_xml || self.get_commandlist)
    self.generate_apis! parsed_commands
  end

  def generate_apis!(parsed_commands)
    @api_version = parsed_commands[:api_version]
    @support_funcs = parsed_commands[:support_funcs]
    @commands = parsed_commands[:commands]
  end


  def get_commandlist
    cgi_request(command: :get_commandlist, method: :get).body
  end

  def cgi_request(command:, method:, query: nil, headers: {})
    uri = URI.parse(api_host).clone
    uri.path = "/#{command}.cgi"
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme === "https"

    headers = DEFAULT_HEADERS.merge(headers)
    path = uri.path

    if query
      path = path + '?' + URI.encode_www_form(query)
    end

    req = Net::HTTP::Get.new(path)
    req.initialize_http_header(headers)

    http.request(req)
  end
end