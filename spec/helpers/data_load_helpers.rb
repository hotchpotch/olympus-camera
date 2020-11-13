
require 'pathname'

module DataLoadHelpers
  def load_data(name)
    File.read Pathname.new(__FILE__).parent.parent.join("data").join(name)
  end
end