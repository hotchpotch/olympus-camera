require "uri"
require "net/http"
require "olympus-camera/version"
require "olympus-camera/any"
require "olympus-camera/commands_parser"
require "xmlsimple"
require "open-uri"

class OlympusCamera
  class APIError < StandardError; end

  DEFAULT_HEADERS = {
    "Connection" => "close",
    "User-Agent" => "OlympusCameraKit",
  }

  DEFAULT_TIMEOUT = {
    open: 1,
    read: 10,
  }

  attr_accessor :api_host, :open_timeout, :read_timeout
  attr_reader :commands, :api_version, :support_funcs

  def initialize(commandlist_xml: nil, api_host: "http://192.168.0.10")
    self.open_timeout = DEFAULT_TIMEOUT[:open]
    self.read_timeout = DEFAULT_TIMEOUT[:read]

    self.api_host = api_host
    parsed_commands = CommandsParser.parse(commandlist_xml || self.raw_get_commandlist.body)
    self.generate_api! parsed_commands
  end

  def generate_api!(parsed_commands)
    @api_version = parsed_commands[:api_version]
    @support_funcs = parsed_commands[:support_funcs]
    @commands = parsed_commands[:commands]

    @commands.each do |name, command_args|
      define_singleton_method(name) do |query = nil, headers: {}, raw_result: false|
        cgi_request(command: name, method: command_args[:method], query: query, headers: headers, raw_result: raw_result)
      end
    end
  end

  def api_list
    @commands.map do |name, command_args|
      queries = command_args[:queries]
      if (queries.length > 0)
        params = queries.map { |query| query.to_h }
        [name.to_s, params]
      else
        [name.to_s]
      end
    end.sort
  end

  def all_images
    pathes = parse_filelist self.get_imglist({ "DIR" => "/DCIM" })
    pathes.map do |path|
      parse_filelist(
        self.get_imglist({ "DIR" => path.join("/") })
      ).map { |d| d.join("/") }
    end.flatten
  end

  def get_image(path_or_params)
    path = path_or_params.kind_of?(Hash) ? path_or_params["DIR"] : path_or_params
    uri = URI.parse(api_host)
    uri.path = path
    uri.read
  end

  def parse_filelist(source)
    if source.match /^VER_100/
      source.split(/\r?\n/)[1..-1].map do |line|
        line.split(",")[0, 2]
      end
    else
      []
    end
  end

  def raw_get_commandlist
    cgi_request(command: :get_commandlist, method: :get, raw_result: true)
  end

  def cgi_request(command:, method:, query: nil, headers: {}, raw_result: false)
    uri = URI.parse(api_host)
    uri.path = "/#{command}.cgi"
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = self.open_timeout
    http.read_timeout = self.read_timeout
    http.use_ssl = uri.scheme === "https"

    headers = DEFAULT_HEADERS.merge(headers)
    path = uri.path

    if method.to_sym == :post
      req = Net::HTTP::Post.new(path)
      if query
        req.set_form_data query
      end
    elsif method.to_sym == :get
      if query
        path = path + "?" + URI.encode_www_form(query)
      end
      req = Net::HTTP::Get.new(path)
    else
      raise ArgumentError.new("method: #{method} is unknown.")
    end

    req.initialize_http_header(headers)
    res = http.request(req)

    if raw_result
      return res
    end

    if res.code.to_i >= 400
      raise APIError.new("API Error: " + res.inspect)
    else
      if res.content_type&.include?("/xml") && res.body.length > 10
        XmlSimple.xml_in res.body
      else
        res.body
      end
    end
  end
end
