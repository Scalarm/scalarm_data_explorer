require 'scalarm/service_core/utils'

module Utils
  # extend this Utils with Scalarm::ServiceCore::Utils module methods
  class << self
    Scalarm::ServiceCore::Utils.singleton_methods.each do |m|
      define_method m, Scalarm::ServiceCore::Utils.method(m).to_proc
    end
  end

  # Returns random public address from IS with https:// prefix
  # If there is no adresses registered - returns nil
  def self.random_data_explorer_public_url
    data_explorer_adresses = Rails.cache.fetch('data_explorer_adresses', expires_in: 30.minutes) do
      InformationService.instance.get_list_of('data_explorers')
    end
    random_address = data_explorer_adresses.try(:sample)

    random_address.nil? ? nil : "https://#{random_address}"
  end
end