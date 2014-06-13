require 'bundler/setup'
Bundler.setup

require 'harrison'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
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

  failure_message_for_should do |block|
    "expected block to call exit(#{exp_code}) but exit" +
      (actual.nil? ? " not called" : "(#{actual}) was called")
  end

  failure_message_for_should_not do |block|
    "expected block not to call exit(#{exp_code})"
  end

  description do
    "expect block to call exit(#{exp_code})"
  end
end

def capture(io_name, &block)
  original = eval("$#{io_name}")
  fake = StringIO.new
  eval("$#{io_name} = fake")

  begin
    yield
  ensure
    eval("$#{io_name} = original")
  end

  fake.string.downcase
end

def harrisonfile_fixture_path(type=:valid)
  File.dirname(__FILE__) + "/fixtures/Harrisonfile.#{type}"
end
