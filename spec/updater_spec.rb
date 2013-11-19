require 'ostruct'
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
    before do
      @dns = CloudDyndns::Updater.new(config, test_logger)
    end

    describe 'when a zone is found' do
      before do
        @mock_zone = {}
        @dns.expects(:find_zone_by_domain).
          with('looting.biz').
          returns(@mock_zone)
      end

      it 'should return that zone' do
        expect(@dns.find_zone_by_name('looting.biz')).to_equal(@mock_zone)
      end
    end

    describe 'when a zone is not found' do
      before do
        @dns.expects(:find_zone_by_domain).
          with('looting.biz').
          returns(nil)
      end

      it 'should create a new zone for the given domain' do
        zone = @dns.find_zone_by_name('looting.biz')

        expect(zone.domain).to_equal 'looting.biz'
      end
    end

    it 'should return a zone' do
      dns = CloudDyndns::Updater.new(config, test_logger)

      result = dns.find_zone_by_name('honk')

      expect(result).to_respond_to :records
    end
  end

  describe '#find_zone_by_domain' do
    before do
      @dns = CloudDyndns::Updater.new(config, test_logger)
    end

    it 'should return a domain if it matches the domain with a trailing "."' do
      zone = @dns.zones.create(
        :domain => 'looting.biz.'
      )
      found_zone = @dns.find_zone_by_domain('looting.biz')

      expect(found_zone.domain).to_equal 'looting.biz.'
    end

    it 'should return nil if not found' do
      @dns.zones.clear()
      found_zone = @dns.find_zone_by_domain('narf.io')

      expect(found_zone).to_be_nil
    end
  end

  describe '#create_zone_by_domain' do
    before do
      @dns = CloudDyndns::Updater.new(config, test_logger)
    end

    it 'should create a zone for the passed domain' do
      zone = @dns.create_zone_by_domain('looting.biz')

      expect(zone.domain).to_equal 'looting.biz'
    end

    it 'should set the :email as hostmaster@{{passed domain}}' do
      @dns.stubs(:zones).returns(mock_zones = mock())

      mock_zones.expects(:create).with(({
          :domain => 'example.com',
          :email => 'hostmaster@example.com'
        })
      )

      @dns.create_zone_by_domain('example.com')
    end
  end

  describe '#records_for_zone' do
    before do
      @dns = CloudDyndns::Updater.new(config, test_logger)
    end

    it 'should get the most up to date records for the zone' do
      zone = mock()
      records = mock()
      zone.expects(:records).returns(records)
      records.expects(:reload)

      @dns.records_for_zone(zone)
    end
  end

  describe '#find_record_for_zone_by_name' do
    before do
      @dns = CloudDyndns::Updater.new(config, test_logger)
    end

    it 'should return the zone if the name matches the given name + "."' do
      zone = @dns.zones.create(:domain => 'horseblood.biz')
      # openstruct because it behaves like the returned object
      record = OpenStruct.new(
        :name => 'phl.horseblood.biz.',
        :value => "8.8.8.8",
        :type => 'A'
      )

      @dns.stubs(:records_for_zone).returns([record])

      expect(@dns.find_record_for_zone_by_name(zone, 'phl.horseblood.biz')).
             to_equal record

    end
  end

  describe '#update_record_for_zone' do

    before do
      @dns = CloudDyndns::Updater.new(config, test_logger)
    end

    describe 'when current_ip is empty' do
      it 'should raise error' do
        @dns.stubs(:get_ip_address).returns('')
        zone   = mock()
        target = 'phl.looting.biz'

        expect(lambda {@dns.update_record_for_zone(zone, target) }).
          to_raise CloudDyndns::Updater::NoIPAddressError
      end
    end

    describe 'when current ip is not empty' do
      before do
        @dns.stubs(:get_ip_address).returns('8.8.4.4')
      end

      describe 'when record does not exist' do
        before do
          @dns.stubs(:find_record_for_zone_by_name).returns(nil)
        end

        it 'should call create_record_for_zone' do
          zone = mock()
          expected_attrs = {
            :name => 'ff.phl.looting.biz',
            :value => '8.8.4.4',
            :ttl => nil
          }

          @dns.expects(:create_record_for_zone).with(zone, expected_attrs)

          @dns.update_record_for_zone(zone, 'ff.phl.looting.biz')
        end
      end

      describe 'when record exists' do
        before do
          @mock_record = mock()
          @dns.stubs(:find_record_for_zone_by_name).returns(@mock_record)
        end

        describe 'and matches current ip address' do
          before do
            @mock_zone = mock()
            @mock_record = OpenStruct.new(
              :name => 'f.phl.narf.io',
              :value => ['8.8.4.4']
            )
            @dns.stubs(:get_ip_address).returns('8.8.4.4')
            @dns.stubs(:find_record_for_zone_by_name).returns(@mock_record)
          end

          it 'should not call :create_record_for_zone' do
            @dns.expects(:create_record_for_zone).never

            @dns.update_record_for_zone(@mock_zone, 'f.phl.narf.io')
          end

          it 'should return record' do
            result = @dns.update_record_for_zone(@mock_zone, 'f.phl.narf.io')

            expect(result).to_equal @mock_record
          end
        end

        describe 'and does not match current ip address' do
          before do
            @mock_zone = mock()
            @mock_record = OpenStruct.new(
              :name => 'f.phl.narf.io',
              :value => ['192.168.1.12']
            )
            @dns.stubs(:get_ip_address).returns('10.30.1.2')
            @dns.stubs(:find_record_for_zone_by_name).returns(@mock_record)
          end

          it 'should destroy the record and create a new record' do
            @mock_record.expects(:destroy)

            @dns.expects(:create_record_for_zone)
            @dns.update_record_for_zone(@mock_zone, 'f.phl.narf.io')
          end

        end
      end
    end
  end

  describe '#update!' do
    describe 'when domains to update are not set' do
      before do
        empty_config = config.clone
        empty_config[:zones].first[:targets] = nil

        @dns = CloudDyndns::Updater.new(empty_config, test_logger)
      end

      it 'should raise error' do
        operation = lambda {
          @dns.update!
        }
        expect(operation).to_raise CloudDyndns::Updater::NoTargetsSpecified
      end
    end

    describe 'when domains are set' do
      before do
        @dns = CloudDyndns::Updater.new(config, test_logger)
      end

      it 'should update the domains for each zone' do
        mock_zone1 = mock()
        mock_zone2 = mock()

        @dns.expects(:find_zone_by_name).
          with('looting.biz').returns(mock_zone1)
        @dns.expects(:find_zone_by_name).
          with('narf.io').returns(mock_zone2)

        @dns.expects(:update_record_for_zone).
          with(mock_zone1, 'phl.looting.biz', config[:zones][0])
        @dns.expects(:update_record_for_zone).
          with(mock_zone1, '*.phl.looting.biz', config[:zones][0])

        @dns.expects(:update_record_for_zone).
          with(mock_zone2, 'phl.narf.io', config[:zones][1])
        @dns.expects(:update_record_for_zone).
          with(mock_zone2, '*.phl.narf.io', config[:zones][1])

        @dns.update!
      end

    end
  end

end
