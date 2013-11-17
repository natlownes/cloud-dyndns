require File.expand_path(File.dirname(__FILE__) + '/test_helper')
root = CloudDyndns::ROOTDIR

config_file_path   = File.join(root, 'spec', 'fixtures', 'config.yml')
test_log_path      = File.join(root, 'spec', 'fixtures', 'test.log')

Fog.mock!
test_logger = Logger.new(test_log_path)
config      = YAML.load_file(config_file_path)


describe 'CloudDyndns::Updater' do

  after do
    FileUtils.rm_rf test_log_path
  end
  describe '.domain_name_to_provider_name' do
    it 'should return the given name appended with a "."' do
      result = CloudDyndns::Updater.domain_name_to_provider_name('ox')

      expect(result).to_equal 'ox.'
    end
  end

  describe '#initialize' do
    it 'should set a dns interface' do
      dns = CloudDyndns::Updater.new(config, test_logger)

      expect(dns.dns).to_respond_to :zones
    end

    it 'should set a log interface' do
      dns = CloudDyndns::Updater.new(config, test_logger)

      expect(dns.log.class).to_equal ::Logger
    end

    it 'should set zone_configs' do
      dns = CloudDyndns::Updater.new(config, test_logger)

      expect(dns.zone_configs).to_not_be_empty
      expect(dns.zone_configs[0][:domain]).to_equal 'looting.biz'
      expect(dns.zone_configs[0][:targets]).to_include 'phl.looting.biz'
    end
  end

  describe '#find_zone_by_name' do
    it 'should return a zone' do
      dns = CloudDyndns::Updater.new(config, test_logger)

      result = dns.find_zone_by_name('honk')

      expect(result).to_respond_to :records
    end
  end

end
