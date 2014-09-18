$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib'))
require 'minitest/autorun'
require 'minitest/pride'
require 'capistrano/wizard'
require 'fileutils'

def flag(set)
  ARGV.clear
  @exit = catch(:system_exit) { command_line(*set) }
end

def command_line(*options)
  options.each { |opt| ARGV << opt }
  def subject.exit(*args)
    throw(:system_exit, :exit)
  end
  subject.run
end

def capture_io
  require 'stringio'

  orig_stdout, orig_stderr         = $stdout, $stderr
  captured_stdout, captured_stderr = StringIO.new, StringIO.new
  $stdout, $stderr                 = captured_stdout, captured_stderr

  yield

  return captured_stdout.string, captured_stderr.string
ensure
  $stdout = orig_stdout
  $stderr = orig_stderr
end

describe Capistrano::Wizard::CLI do
  subject { Capistrano::Wizard::CLI.new }

  before do
    FileUtils.rm_rf('/tmp/capistrano-wizard-test')
    Dir.mkdir('/tmp/capistrano-wizard-test')
    Dir.chdir('/tmp/capistrano-wizard-test')
  let(:default_arguments) do
    [
      '--name', 'test_app',
      '--repo-url', 'git@github.com:user/repo.git',
      '--deploy-to', '~/www/app',
      '--skip-ruby-manager',
      '--rails',
      '--stages'
    ]
  end
  end

  it 'prints note' do
    out, _ = capture_io { flag default_arguments }
    out.must_match /gem 'capistrano'/
  end

  it 'create 4 files for default arguments' do
    out, _ = capture_io { flag default_arguments }
    File.exist?('result/Capfile').must_equal true
    File.exist?('result/config/deploy.rb').must_equal true
    File.exist?('result/config/deploy/staging.rb').must_equal true
    File.exist?('result/config/deploy/production.rb').must_equal true
  end

  it 'sets application name with --name argument' do
    args = default_arguments
    args[1] = 'new_test_name'
    out, _ = capture_io { flag args }
    File.read('result/config/deploy.rb').must_match /^set :application, 'new_test_name'/
  end

  it 'sets repo_url with --repo-url argument' do
    args = default_arguments
    args[3] = 'git@github.com:discourse/discourse.git'
    out, _ = capture_io { flag args }
    File.read('result/config/deploy.rb').must_match /^set :repo_url, 'git@github\.com:discourse\/discourse\.git'/
  end

  it 'sets deploy_to with --deploy-to argument' do
    args = default_arguments
    args[5] = '/var/www/app'
    out, _ = capture_io { flag args }
    File.read('result/config/deploy.rb').must_match /^set :deploy_to, '\/var\/www\/app'/
  end

  it 'do not add any info about ruby managers with --skip-ruby-manager argument' do
    out, _ = capture_io { flag default_arguments }
    File.read('result/Capfile').wont_match /require.+rvm/
    File.read('result/Capfile').wont_match /require.+rbenv/
    File.read('result/Capfile').wont_match /require.+chruby/
    File.read('result/config/deploy.rb').wont_match /rvm/
    File.read('result/config/deploy.rb').wont_match /rbenv/
    File.read('result/config/deploy.rb').wont_match /chruby/
  end

  it 'add rvm as ruby manager with --rvm argument' do
    args = default_arguments
    args[6] = '--rvm'
    out, _ = capture_io { flag args }
    File.read('result/Capfile').must_match /require.+rvm/
    File.read('result/Capfile').wont_match /require.+rbenv/
    File.read('result/Capfile').wont_match /require.+chruby/
    File.read('result/config/deploy.rb').must_match /rvm/
    File.read('result/config/deploy.rb').must_match /rvm_ruby_version.+2\.0\.0-p247/
    File.read('result/config/deploy.rb').wont_match /rbenv/
    File.read('result/config/deploy.rb').wont_match /chruby/
  end

  it 'add rvm as ruby manager with --rvm 2.1.0 argument and set version to 2.1.0' do
    args = default_arguments
    args[6] = ['--rvm', '2.1.0']
    out, _ = capture_io { flag args.flatten }
    File.read('result/Capfile').must_match /require.+rvm/
    File.read('result/Capfile').wont_match /require.+rbenv/
    File.read('result/Capfile').wont_match /require.+chruby/
    File.read('result/config/deploy.rb').must_match /rvm/
    File.read('result/config/deploy.rb').must_match /rvm_ruby_version.+2\.1\.0/
    File.read('result/config/deploy.rb').wont_match /rbenv/
    File.read('result/config/deploy.rb').wont_match /chruby/
  end

  it 'add rbenv as ruby manager with --rbenv argument' do
    args = default_arguments
    args[6] = '--rbenv'
    out, _ = capture_io { flag args }
    File.read('result/Capfile').wont_match /require.+rvm/
    File.read('result/Capfile').must_match /require.+rbenv/
    File.read('result/Capfile').wont_match /require.+chruby/
    File.read('result/config/deploy.rb').wont_match /rvm/
    File.read('result/config/deploy.rb').must_match /rbenv/
    File.read('result/config/deploy.rb').must_match /rbenv_ruby.+2\.0\.0-p247/
    File.read('result/config/deploy.rb').wont_match /chruby/
  end

  it 'add rbenv as ruby manager with --rbenv 2.1.0 argument and set version to 2.1.0' do
    args = default_arguments
    args[6] = ['--rbenv', '2.1.0']
    out, _ = capture_io { flag args.flatten }
    File.read('result/Capfile').wont_match /require.+rvm/
    File.read('result/Capfile').must_match /require.+rbenv/
    File.read('result/Capfile').wont_match /require.+chruby/
    File.read('result/config/deploy.rb').wont_match /rvm/
    File.read('result/config/deploy.rb').must_match /rbenv/
    File.read('result/config/deploy.rb').must_match /rbenv_ruby.+2\.1\.0/
    File.read('result/config/deploy.rb').wont_match /chruby/
  end

  it 'add chruby as ruby manager with --chruby argument' do
    args = default_arguments
    args[6] = '--chruby'
    out, _ = capture_io { flag args }
    File.read('result/Capfile').wont_match /require.+rvm/
    File.read('result/Capfile').wont_match /require.+rbenv/
    File.read('result/Capfile').must_match /require.+chruby/
    File.read('result/config/deploy.rb').wont_match /rvm/
    File.read('result/config/deploy.rb').wont_match /rbenv/
    File.read('result/config/deploy.rb').must_match /chruby/
    File.read('result/config/deploy.rb').must_match /chruby_ruby.+2\.0\.0-p247/
  end

  it 'add chruby as ruby manager with --chruby 2.1.0 argument and set version to 2.1.0' do
    args = default_arguments
    args[6] = ['--chruby', '2.1.0']
    out, _ = capture_io { flag args.flatten }
    File.read('result/Capfile').wont_match /require.+rvm/
    File.read('result/Capfile').wont_match /require.+rbenv/
    File.read('result/Capfile').must_match /require.+chruby/
    File.read('result/config/deploy.rb').wont_match /rvm/
    File.read('result/config/deploy.rb').wont_match /rbenv/
    File.read('result/config/deploy.rb').must_match /chruby/
    File.read('result/config/deploy.rb').must_match /chruby_ruby.+2\.1\.0/
  end

  it 'add rails plugin with --rails argument' do
    out, _ = capture_io { flag default_arguments }
    File.read('result/Capfile').must_match /require.+rails/
  end

  it 'do not add rails plugin with --no-rails argument' do
    args = default_arguments
    args[-2] = ['--no-rails', '--no-bundler']
    out, _ = capture_io { flag args.flatten }
    File.read('result/Capfile').wont_match /require.+rails/
  end

  it 'add bundler plugin with --bundler argument' do
    args = default_arguments
    args[-2] = ['--no-rails', '--bundler']
    out, _ = capture_io { flag args.flatten }
    File.read('result/Capfile').must_match /require.+bundler/
  end

  it 'do not add bundler plugin with --no-bundler argument' do
    args = default_arguments
    args[-2] = ['--no-rails', '--no-bundler']
    out, _ = capture_io { flag args.flatten }
    File.read('result/Capfile').wont_match /require.+bundler/
  end

  it 'add config files for each stage name passed to --stages argument' do
    args = default_arguments << 'test,prod'
    out, _ = capture_io { flag args }
    File.exist?('result/config/deploy/staging.rb').must_equal false
    File.exist?('result/config/deploy/production.rb').must_equal false
    File.exist?('result/config/deploy/test.rb').must_equal true
    File.exist?('result/config/deploy/prod.rb').must_equal true
  end

  it 'with --version option shoud show version' do
    out, _ = capture_io { flag '--version' }
    out.must_match /\d+\.\d+\.\d+/
  end

  it 'with --help option shoud show app help' do
    out, _ = capture_io { flag '--help' }
    out.lines.first.must_match /cap-wizard \[options\]/
  end
end
