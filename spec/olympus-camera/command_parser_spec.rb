
RSpec.describe OlympusCamera::CommandsParser do
  CommandsParser = OlympusCamera::CommandsParser
  ANY = OlympusCamera::ANY

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
        [["com", "assignafframe"], ["point", ANY]],
        [["com", "releaseafframe"]],
        [["com", "takeready"], ["point", ANY]],
        [["com", "starttake"], ["point", ANY], ["exposuremin", ANY], ["upperlimit", ANY]],
        [["com", "stoptake"]],
        [["com", "startmovietake"], ["limitter", ANY], ["liveview", "on"]],
        [["com", "stopmovietake"]],
      ],
    })
    expect(commands[:get_imglist]).to eq({
      method: :get,
      queries: [[["DIR", ANY]]],
    })
  end

  it "e-m1-mark2.xml" do
    xml = load_data("e-m1-mark2.xml")
    parsed = CommandsParser.parse(xml)
    expect(parsed[:api_version]).to eq("4.10")
    expect(parsed[:support_funcs]).to eq(["web", "remote", "gps", "release", "moviestream"])

    commands = parsed[:commands]
    expect(commands[:exec_pwoff]).to eq({
      method: :get,
      queries: [[["mode", ANY]]],
    })

    expect(commands[:exec_takemotion]).to eq({
      method: :get,
      queries: [
        [["com", "assignafframe"], ["point", ANY]],
        [["com", "releaseafframe"]],
        [["com", "takeready"], ["point", ANY]],
        [["com", "starttake"], ["point", ANY], ["exposuremin", ANY], ["upperlimit", ANY]],
        [["com", "stoptake"]],
        [["com", "startmovietake"], ["limitter", ANY], ["liveview", "on"]],
        [["com", "stopmovietake"]],
      ],
    })
    expect(commands[:get_imglist]).to eq({
      method: :get,
      queries: [[["DIR", ANY]]],
    })
  end

  it "e-m1-mark3.xml" do
    xml = load_data("e-m1-mark3.xml")
    parsed = CommandsParser.parse(xml)
    expect(parsed[:api_version]).to eq("4.40")
    expect(parsed[:support_funcs]).to eq(["web", "remote", "gps", "release", "moviestream", "firmup", "mysetbackup", "cameralog"])

    commands = parsed[:commands]
    expect(commands[:exec_pwoff]).to eq({
      method: :get,
      queries: [[["mode", "withble"]]],
    })

    expect(commands[:exec_takemotion]).to eq({
      method: :get,
      queries: [
        [["com", "assignafframe"], ["point", ANY]],
        [["com", "releaseafframe"]],
        [["com", "takeready"], ["point", ANY]],
        [["com", "starttake"], ["point", ANY], ["exposuremin", ANY], ["upperlimit", ANY]],
        [["com", "stoptake"]],
        [["com", "startmovietake"], ["limitter", ANY], ["liveview", "on"]],
        [["com", "stopmovietake"]],
      ],
    })
    expect(commands[:get_imglist]).to eq({
      method: :get,
      queries: [[["DIR", ANY]]],
    })
  end
end