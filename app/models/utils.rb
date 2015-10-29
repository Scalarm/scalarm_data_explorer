require 'scalarm/service_core/utils'

module Utils
  # extend this Utils with Scalarm::ServiceCore::Utils module methods
  class << self
    Scalarm::ServiceCore::Utils.singleton_methods.each do |m|
      define_method m, Scalarm::ServiceCore::Utils.method(m).to_proc
    end
  end

  # TODO: A good candidate to generic function in Scalarm::ServiceCore
  # Returns random public address from IS with https:// prefix
  # If there is no adresses registered - returns nil
  # Arguments:
  # * service - plurar name of service - e.g. data_explorers
  def self.random_service_public_url(service)
    addresses = Rails.cache.fetch("#{service}_adresses", expires_in: 30.minutes) do
      InformationService.instance.get_list_of(service)
    end

    random_address = addresses.try(:sample)
    random_address.nil? ? nil : "https://#{random_address}"
  end

end