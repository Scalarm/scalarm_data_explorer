unless Rails.env.test?
  unless Scalarm::Database::MongoActiveRecord.connected?
    Scalarm::Database::MongoActiveRecord.connection_init('localhost', 'scalarm_db')
  end
end
