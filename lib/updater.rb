require 'open-uri'
require 'fog'


class CloudDyndns::Updater
  class NoIPAddressError < StandardError
    def message
      "could not get your current ip address: \n
       cowardly refusing to update your DNS record to nothing"
    end
  end

  class NoTargetsSpecified < StandardError
    def message
      "no domain names to update were specified"
    end
  end

  def self.domain_name_to_provider_name(name)
    "#{name}."
  end

  def initialize(config_object, logger)
    @credentials  = config_object[:credentials]
    @log          = logger
    @zone_configs = config_object[:zones]
  end

  def update!
    updates = []
    zone_configs.each do |zone_config|
      targets        = zone_config[:targets]
      top_level_zone = zone_config[:domain]

      check_config_targets(top_level_zone, targets)

      zone = find_zone_by_name(top_level_zone)

      targets.each do |target|
        updates << update_record_for_zone(zone, target, zone_config)
      end
    end

    updates = []
  end

  def zones
    dns.zones
  end

  def dns
    @dns ||= create_dns(@credentials)
  end

  def log
    @log
  end

  def zone_configs
    @zone_configs || []
  end

  def find_zone_by_name(zone_domain)
    find_zone_by_domain(zone_domain) or create_zone_by_domain(zone_domain)
  end

  def find_zone_by_domain(domain_name)
    zones.find do |z|
      z.domain.match(%r{#{domain_name}\.$})
    end
  end

  def create_zone_by_domain(domain_name)
    zones.create({
      :domain => domain_name,
      :email =>  "hostmaster@#{domain_name}"
    })
  end

  def records_for_zone(zone)
    zone.records.reload
  end

  def find_record_for_zone_by_name(zone, name)
    records_for_zone(zone).find do |r|
      r.name == self.class.domain_name_to_provider_name(name)
    end
  end

  def update_record_for_zone(zone, target, zone_config={})
    # zone is the zone object from Fog
    # target is a string, like "*.example.com"
    # or just name.example.com" or just
    # "example.com"
    # zone_config is the object from the zones array
    # in the yaml config
    current_ip = get_ip_address()

    if current_ip.empty?
      raise NoIPAddressError.new
    end

    record     = find_record_for_zone_by_name(zone, target)

    target_attributes = {
      :name => target,
      :value => current_ip,
      :ttl => zone_config[:ttl]
    }

    if is_record_create?(record)
      return create_record_for_zone(zone, target_attributes)
    end

    if is_record_update?(record)
      record.destroy
      return create_record_for_zone(zone, target_attributes)
    end

    record
  end

  private

  def check_config_targets(top_level_zone, targets)
    if !targets or targets.empty?
      @log << %{
      #{top_level_zone} has zero targets in config, add some domains to update in your config file
      }
      raise NoTargetsSpecified.new
    end
  end

  def create_dns(credentials)
    Fog::DNS.new(credentials)
  end

  def default_ttl
    300
  end

  def get_ip_address
    ip_url = "http://wtfismyip.com/text"

    @external_ip ||=  OpenURI.open_uri(ip_url).read.strip
  end

  def is_record_create?(record)
    !record
  end

  def is_record_update?(record)
    # record exists and is not our external ip
    external_ip = get_ip_address()
    record && !record.value.include?(external_ip)
  end

  def create_record_for_zone(zone, attrs={})
    attributes = {
      :ttl => (attrs[:ttl] || default_ttl()),
      :value => attrs[:value],
      :name => attrs[:name],
      :type => 'A'
    }
    zone.records.create(attributes)
    @log << "created record: #{attributes.to_yaml}"
  end

end
