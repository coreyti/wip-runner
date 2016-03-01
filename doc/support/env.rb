$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'rspec'
require 'wip/runner/spec/matchers'
include WIP::Runner::Spec::Matchers::Addons

Specdown::Config.expectations = :rspec

# def `(command)
#   result = StringIO.new
#
#   Open3.popen3(@env, command) do |stdin, stdout, stderr, thread|
#     status = thread.value
#
#     while line = stdout.gets
#       result.puts stdout.lines
#     end
#     #
#     # unless status.success?
#     #   exit 1
#     # end
#   end
#
#   result.string
# end
