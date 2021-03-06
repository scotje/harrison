require 'bundler/setup'
Bundler.setup

require 'simplecov'
SimpleCov.start

require 'harrison'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

RSpec::Matchers.define :exit_with_code do |exp_code|
  actual = nil

  match do |block|
    begin
      block.call
    rescue SystemExit => e
      actual = e.status
    end
    actual and actual == exp_code
  end

  failure_message do |block|
    "expected block to call exit(#{exp_code}) but exit" +
      (actual.nil? ? " not called" : "(#{actual}) was called")
  end

  failure_message_when_negated do |block|
    "expected block not to call exit(#{exp_code})"
  end

  description do
    "expect block to call exit(#{exp_code})"
  end
end

def capture(io_names = [ :stdout, :stderr ], &block)
  original_ios = {}
  fake_ios = {}

  io_names = [ io_names ] unless io_names.respond_to?(:each)

  io_names.each do |io_name|
    original_ios[io_name] = eval("$#{io_name}")
    fake_ios[io_name] = StringIO.new

    eval("$#{io_name} = fake_ios[io_name]")
  end

  begin
    yield
  ensure
    io_names.each do |io_name|
      eval("$#{io_name} = original_ios[io_name]")
    end
  end

  if io_names.size == 1
    return fake_ios[io_names.first].string.downcase
  else
    return fake_ios.each { |io, output| fake_ios[io] = output.string.downcase }
  end
end

def fixture_path
  File.dirname(__FILE__) + "/fixtures"
end

def harrisonfile_fixture_path(type=nil)
  if type
    fixture_path + "/Harrisonfile.#{type}"
  else
    fixture_path + "/Harrisonfile"
  end
end
