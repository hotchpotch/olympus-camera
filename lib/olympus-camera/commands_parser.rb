
require 'xmlsimple'

class OlympusCamera
  module CommandsParser
    module_function

    def parse(xml)
      raw_commands = XmlSimple.xml_in xml
      api_version = raw_commands["version"][0]
      support_funcs = raw_commands["support"].map {|v| v["func"] }
      commands = normalize_cgi_commands raw_commands["cgi"]
      {
        api_version: api_version,
        support_funcs: support_funcs,
        commands: commands,
      }
    end

    def normalize_cgi_commands(cgi_commands)
      commands = {}
      cgi_commands.each do |data|
        name = data["name"]
        http_method = data["http_method"][0]

        method = http_method["type"].to_sym
        queries = get_pair_queries(http_method)

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
      end.select {|a| a }
      tail_array(q)
    end

  end
end