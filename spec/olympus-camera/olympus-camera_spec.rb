RSpec.describe OlympusCamera do
  it "has a version number" do
    expect(OlympusCamera::VERSION).not_to be nil
  end

  describe "generate_apis!" do
    it "pen_f.xml" do
      xml = load_data("pen_f_testing.xml")
      camera = OlympusCamera.new(commandlist_xml: xml)
      expect(camera.api_version).to eq("2.60")
      expect(camera.support_funcs).to eq(["web", "remote", "gps", "release"])

      # expect(camera.commands[:exec_pwoff]).to eq({
      #   method: :get,
      #   queryies: [],
      # })

      expect(camera.commands[:exec_takemotion]).to eq({
        method: :get,
        queries: [
          [["com", "assignafframe"], ["point", :any]],
          [["com", "releaseafframe"]],
          [["com", "takeready"], ["point", :any]],
          [["com", "starttake"], ["point", :any], ["exposuremin", :any], ["upperlimit", :any]],
          [["com", "stoptake"]],
          [["com", "startmovietake"], ["limitter", :any], ["liveview", ["on"]]],
          [["com", "stopmovietake"]],
        ],
      })
      # expect(camera.commands[:get_imglist]).to eq({
      #   method: :get,
      #   query_type: [{DIR: nil}],
      # })
    end
  end
end

__END__

<cgi name="exec_takemotion">
<http_method type="get">
<cmd1 name="com">
<param1 name="assignafframe">
<cmd2 name="point"/>
</param1>
<param1 name="releaseafframe"/>
<param1 name="takeready">
<cmd2 name="point"/>
</param1>

<param1 name="starttake">
<cmd2 name="point">
<cmd3 name="exposuremin"/>
<cmd3 name="upperlimit"/>
</cmd2>
</param1>

<param1 name="stoptake"/>
<param1 name="startmovietake">
<cmd2 name="limitter"/>
<cmd3 name="liveview">
<param3 name="on"/>
</cmd3>
</param1>
<param1 name="stopmovietake"/>
</cmd1>
</http_method>
</cgi>