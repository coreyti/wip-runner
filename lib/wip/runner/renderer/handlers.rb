module WIP::Runner::Renderer
  module Handlers ; end
end

Dir[File.expand_path('../handlers/*.rb', __FILE__)].each { |f| require(f) }
