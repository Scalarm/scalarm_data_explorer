[![Build Status](https://travis-ci.org/Dragner8/scalarm_data_explorer.svg?branch=master)](https://travis-ci.org/Dragner8/scalarm_data_explorer)   [![](https://images.microbadger.com/badges/version/scalarm/scalarm_data_explorer.svg)](https://microbadger.com/images/scalarm/scalarm_data_explorer "Get your own version badge on microbadger.com")   [![](https://images.microbadger.com/badges/image/scalarm/scalarm_data_explorer.svg)](https://microbadger.com/images/scalarm/scalarm_data_explorer "Get your own image badge on microbadger.com")


![Scalarm Logo](http://scalarm.com/images/scalarmNiebieskiemale.png)

Scalarm Data Explorer
==========================

Data Explorer is a component of the Scalarm platform. This module is responsible for
analysis and visualization of Farming Data experiments results.

To run the services you need to fulfil the following requirements:

Ruby version
------------

Currently we use and test Scalarm against MRI 2.1.x but the Rubinius version of Ruby should be good as well.

Please install Ruby with RVM as described on http://rvm.io/
```
\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1
```

Follow installation instructions and reload shell on the end if necessary.


System dependencies
-------------------

* R
* MongoDB
* any dependency required by native gems

Some requirements will be installed by rvm also during ruby installation.


Installation
------------

You can download it directly from GitHub

```
git clone https://github.com/Scalarm/scalarm_data_explorer.git
```

After downloading the code you just need to install gem requirements:

```
cd scalarm_data_explorer
bundle install
```

if any dependency is missing you will be noticed :)


Configuration
-------------

There are two files with configuration: config/secrets.yml and config/puma.rb.

The "secrets.yml" file is a standard configuration file added in Rails 4 to have a single place for all secrets in
an application. We used this approach in our Scalarm platform. Data Explorer stores access data to
Information Service in this file:

```
default: &DEFAULT
  ## cookies enctyption key - set the same in each ExperimentManager to allow cooperation
  secret_key_base: "<you need to change this - with $rake secret>"

  ## InformationService - a service locator
  information_service_url: "localhost:11300"
  information_service_user: "<set to custom name describing your Scalarm instance>"
  information_service_pass: "<generate strong password instead of this>"
  ## uncomment, if you want to communicate through HTTP with Scalarm Information Service
  # information_service_development: true

  cors:
    ## By default all origins are allowed
    allow_all_origins: true

    ## If setting allow_all_origins to false, list all allowed origins below
    allowed_origins:
      - 'https://localhost:3001'
      - 'http://localhost:3000'
      - 'https://localhost'

  ## Database configuration
  ## name of MongoDB database, it is scalarm_db by default
  database:
      db_name: 'scalarm_db'
      ## key for symmetric encryption of secret database data - please change it in production installations!
      ## NOTICE: this key should be set ONLY ONCE BEFORE first run - if you change or lost it, you will be UNABLE to read encrypted data!
      db_secret_key: "QjqjFK}7|Xw8DDMUP-O$yp"

  ## Uncomment, if you want to communicate through HTTP with Scalarm Storage Manager
  # storage_manager_development: true

  ## Configuration of optional Scalarm LoadBalancer (https://github.com/Scalarm/scalarm_load_balancer)
  load_balancer:
      # if you installed and want to use scalarm custom load balancer set to false
      disable_registration: true
      # if you use load balancer you need to specify multicast address (to receive load balancer address)
      #multicast_address: "224.1.2.3:8000"
      # if you use load balancer on http you need to specify this
      #development: true
      # if you want to run and register service in load balancer on other port than default
      #port: "3000"

production:
  <<: *DEFAULT

  ## In production environments some settings should not be stored in configuration file
  ## for security reasons.
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  information_service_url: "<%= ENV["INFORMATION_SERVICE_URL"] %>"
  information_service_user: "<%= ENV["INFORMATION_SERVICE_LOGIN"] %>"
  information_service_pass: "<%= ENV["INFORMATION_SERVICE_PASSWORD"] %>"
  database:
    # share development db with production db by default
    db_name: 'scalarm_db'
    db_secret_key: "<%= ENV["DB_SECRET_KEY"] %>"

development:
  <<: *DEFAULT

test:
  <<: *DEFAULT
```
The example file is placed in config/secrets.yml.example and will be copied to config/secrets.yml if there is no configuration.

In the "config/puma.rb" configuration of the PUMA web server is stored:

```
environment 'production'
daemonize

bind 'unix:/tmp/scalarm_data_explorer.sock'

stdout_redirect 'log/puma.log', 'log/puma.log.err', true
pidfile 'puma.pid'

threads 1,4     # 1-4 threads
# workers 2       # 2 processes
```
The example file is placed in config/puma.rb.example and will be copied to config/puma.rb if there is no configuration.


Please remember to set RAILS_ENV=production when running in the production mode.

```
export RAILS_ENV=production
```

To start/stop the service you can use the provided Rakefile:

```
rake service:start
rake service:stop
```

Before the first start (in the production mode) of the service you need to compile assets:

```
rake service:non_digested
```

With the configuration as above Data Explorer will be listening on linux socket. To make it available for other services we will use a HTTP server - nginx - which will also handle SSL.

To configure NGINX you basically need to add some information to NGINX configuration, e.g. in the /etc/nginx/conf.d/default.conf file.

```
# ================ SCALARM DATA EXPLORERS
upstream scalarm_data_explorer {
           server localhost:25001;
           server unix:/tmp/scalarm_data_explorer.sock;
         }

server {
  listen 25000 ssl default_server;
  client_max_body_size 0;

  ssl_certificate server.crt;
  ssl_certificate_key server.key;

  #ssl_verify_client optional;
  #ssl_client_certificate /etc/grid-security/certificates/PolishGrid.pem;
  #ssl_verify_depth 5;
  ssl_session_timeout 30m;
  #crl list
  #ssl_crl /etc/grid-security/certificates/all.crl.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

  location / {
      proxy_pass http://scalarm_data_explorer;

  proxy_set_header SSL_CLIENT_S_DN $ssl_client_s_dn;
  proxy_set_header SSL_CLIENT_I_DN $ssl_client_i_dn;
  proxy_set_header SSL_CLIENT_VERIFY $ssl_client_verify;
  proxy_set_header SSL_CLIENT_CERT $ssl_client_cert;
  proxy_set_header X-Real-IP  $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header Host $http_host;
  proxy_set_header X-Forwarded-Proto https; # New header for SSL

  break;
}
}
```

One last thing to do is to register Data Explorer in the Scalarm Information Service. With the presented configuration (and assuming we are working on a hypothetical IP address 172.16.67.77) we just need to:
```
curl -k -u scalarm:scalarm --data "address=172.16.67.77" https://localhost:11300/data_explorers
```


License
-------------

MIT
