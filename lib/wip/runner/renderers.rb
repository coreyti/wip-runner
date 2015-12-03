module WIP
  module Runner
    module Renderers ; end
  end
end

Dir[File.expand_path('../renderers/*.rb', __FILE__)].each { |f| require(f) }
