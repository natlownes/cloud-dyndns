require File.expand_path(File.dirname(__FILE__) + '/test_helper')
root = CloudDyndns::ROOTDIR

config_file_path   = File.join(root, 'spec', 'fixtures', 'config.yml')
test_log_path      = File.join(root, 'spec', 'fixtures', 'test.log')
cloud_dyndyns_path = File.join(root, 'bin', 'cloud-dyndns')


describe 'option parsing' do

  describe  'with no options' do
    it 'should exit with exit code 1' do
      exited_status_zero = system(cloud_dyndyns_path)

      expect(exited_status_zero).to_equal false
    end

    it 'should print the usage banner to stdout' do
      out = `#{cloud_dyndyns_path}`

      expect(out).to_match(/USAGE:  cloud-dyndns/)
    end

  end

  describe 'with invalid --config' do

    it 'should raise MissingArgument' do
      args = ['--config']

      expect { CloudDyndns::Config.new(args) }.
        to_raise OptionParser::MissingArgument
    end

  end

  describe 'with valid options' do
    after do
      FileUtils.rm_rf(test_log_path)
    end

    it 'should read the config file' do
      args = ['--config', config_file_path]
      config = CloudDyndns::Config.new(args)

      expect(config.config[:credentials][:provider]).to_equal 'AWS'
      expect(config.config[:zones][0][:domain]).to_equal 'looting.biz'
      expect(config.config[:zones][1][:domain]).to_equal 'narf.io'

      expect(
        config.config[:credentials][:aws_secret_access_key]
      ).to_equal 'honk-secret'

      expect(
        config.config[:credentials][:aws_access_key_id]
      ).to_equal 'honk-key'
    end

    describe 'with no log option' do
      it 'should set a log to stdout' do
        args = ['--config', config_file_path]
        config = CloudDyndns::Config.new(args)

        logdev = config.log.instance_variable_get :@logdev

        expect(logdev.dev).to_equal $stdout
      end
    end

    describe 'with a log option' do
      it 'should create a file at that path' do
        args = ['--config', config_file_path, '--log', test_log_path]
        config = CloudDyndns::Config.new(args)

        logdev = config.log.instance_variable_get :@logdev

        expect(logdev.filename).to_equal test_log_path
      end
    end

  end #valid options
end
