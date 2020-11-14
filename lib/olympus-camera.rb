
require 'uri'
require 'xmlsimple'
require "olympus-camera/version"

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
    self.generate_apis! commandlist_xml || self.get_commandlist
  end

  def generate_apis!(xml)
    raw_commands = XmlSimple.xml_in xml
    @api_version = raw_commands["version"][0]
    @support_funcs = raw_commands["support"].map {|v| v["func"] }
    @commands = normalize_commands raw_commands["cgi"]
  end


  def normalize_commands(cgi_commands)
    commands = {}
    cgi_commands.each do |data|
      name = data["name"]
      http_method = data["http_method"][0]

      method = http_method["type"].to_sym
      queries = get_pair_queries(http_method)
      pp queries

      commands[name.to_sym] = {
        method: method,
        queries: queries,
      }
    end
    commands
  end

  def tail_array(array, r = [])
    array.each {|a| 
      if a[0] && a[0].kind_of?(Array)
        tail_array a, r
      else
        r << a
      end
    }
    r
  end

  def get_pair_queries(root)
    qs = append_queries_walk_node([], [root])
    pp qs
    puts '----'
    qs.map {|q| 
      Array.new((q.length / 2).floor).map { [q.shift, q.shift] }
    }
  end

  def append_queries_walk_node(queries, nodes, n = 1)
    q = nodes.map do |node|
      commands = node["cmd#{n}"]
      commands_1 = node["cmd#{n + 1}"]
      name = node["name"]
      if commands
        appended = append_queries_walk_node(name ? queries + [name] : queries, commands, n)
        if commands_1
          # for
          # <param1 name="startmovietake">
          #  <cmd2 name="limitter"/>
          #  <cmd3 name="liveview">
          #   <param3 name="on"/>
          #  </cmd3>
          # </param1
          target = node.clone
          target.delete("cmd#{n}")
          target.delete("name")
          appended = (appended + append_queries_walk_node([], [target], n + 1)).flatten
        end
        appended
      elsif commands_1
        appended = append_queries_walk_node([], commands_1, n)
        queries + [name, :any] + appended.flatten
      else
        params = node["param#{n}"]
        if params && name
          append_queries_walk_node(queries + [name], params, n + 1)
        elsif name
          if queries.length == 1
            queries + [name]
          else
            queries + [name, :any]
          end
        else
          nil
        end
      end
    end
    tail_array(q)
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