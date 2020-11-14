
RSpec.describe OlympusCamera::CommandsParser do
  CommandsParser = OlympusCamera::CommandsParser

  it "pen_f.xml" do
    xml = load_data("pen_f.xml")
    parsed = CommandsParser.parse(xml)
    expect(parsed[:api_version]).to eq("2.60")
    expect(parsed[:support_funcs]).to eq(["web", "remote", "gps", "release"])

    commands = parsed[:commands]
    expect(commands[:exec_pwoff]).to eq({
      method: :get,
      queries: [],
    })

    expect(commands[:exec_takemotion]).to eq({
      method: :get,
      queries: [
        [["com", "assignafframe"], ["point", :any]],
        [["com", "releaseafframe"]],
        [["com", "takeready"], ["point", :any]],
        [["com", "starttake"], ["point", :any], ["exposuremin", :any], ["upperlimit", :any]],
        [["com", "stoptake"]],
        [["com", "startmovietake"], ["limitter", :any], ["liveview", "on"]],
        [["com", "stopmovietake"]],
      ],
    })
    expect(commands[:get_imglist]).to eq({
      method: :get,
      queries: [[["DIR", :any]]],
    })
  end
end