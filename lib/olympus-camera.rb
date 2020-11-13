
require 'uri'
require 'xmlsimple'
require "olympus-camera/version"

class OlympusCamera
  DEFAULT_HEADERS = {
      "Connection" => 'close',
      "User-Agent" =>  'OlympusCameraKit',
  }

  attr_accessor :api_host

  def initialize(commandlist_xml: nil, api_host: "http://192.168.0.10")
    self.api_host = api_host
    self.generate_apis! commandlist_xml || self.get_commandlist
  end

  def generate_apis!(xml)
    commands = XmlSimple.xml_in xml
  end

  def get_commandlist
    cgi_request(:get_commandlist).body
  end

  def cgi_request(cmd:, query: nil, headers: {})
    uri = URI.parse(api_host).clone
    uri.path = "/#{cmd}.cgi"
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