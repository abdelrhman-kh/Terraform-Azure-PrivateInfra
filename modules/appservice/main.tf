variable "subnet_ids" {
  description = "Map of subnet ids from the network module"
  type        = map(string)
}

# Step 1: Generate a random string
resource "random_password" "secret_part" {
  length  = 50
  special = false # Set to true if you want special characters
}

# Step 2: Concatenate and encode the random string
# Using `local` to define combined encoded string
locals {
  combined_encoded_string = "${var.other_part}${base64encode(random_password.secret_part.result)}"
}


# App Service Plan for Linux
resource "azurerm_service_plan" "appservice_plan" {
  name                = lower("${var.app_service_plan_name}-${var.resource_suffix}")
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  os_type             = "Linux"   # Correct OS type for Linux
  sku_name            = "P2v3"    # Correct argument for SKU

}

# Add Autoscaling for the App Service Plan
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "myAutoscaleSetting"
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  location            = var.location
  target_resource_id  = azurerm_service_plan.appservice_plan.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 5
    }

    # CPU Scale-out rule
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.appservice_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }

    # CPU Scale-in rule
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.appservice_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }

    # Memory Scale-out rule
    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"            # Custom metric name for memory usage
        metric_resource_id = azurerm_service_plan.appservice_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80                           # Scale out when memory usage exceeds 75%
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }

    # Memory Scale-in rule
    rule {
      metric_trigger {
        metric_name        = "MemoryPercentage"            # Custom metric name for memory usage
        metric_resource_id = azurerm_service_plan.appservice_plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 50                           # Scale in when memory usage drops below 50%
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M"
      }
    }
  }
}


# Private Endpoint for App Service
resource "azurerm_private_endpoint" "appservice_pep" {
  name                = lower("${var.app_service_pep_name}-${var.resource_suffix}")
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  subnet_id           = var.subnet_ids["snet-dcai-prod-pep-uaen-001-${var.resource_suffix}"] # Use the private endpoint subnet passed from the root module

  private_service_connection {
    name                           = lower("${var.private_service_connection_name}-${var.resource_suffix}")
    private_connection_resource_id = azurerm_linux_web_app.appservice.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sites-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sites_private_dns_zone.id]
  }
}

resource "azurerm_private_dns_zone" "sites_private_dns_zone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
}


# Linux Web App
resource "azurerm_linux_web_app" "appservice" {
  name                = lower("${var.app_service_name}-${var.resource_suffix}")
  location            = var.location
  resource_group_name = lower("${var.resource_group_name}-${var.resource_suffix}")
  service_plan_id     = azurerm_service_plan.appservice_plan.id

  site_config {

    application_stack {
      php_version = "8.3"
    }

    health_check_path                                   = "/up"
    health_check_eviction_time_in_min                   = 10
    
  }

  app_settings = {
    "APP_DEBUG"                                       = false
    "APP_ENV"                                         = "production"
    "APP_FAKER_LOCALE"                                = "en_US"
    "APP_FALLBACK_LOCALE"                             = "en"
    "APP_KEY"                                         = "base64:+JSAJbmgpbpJyeWEKgGEetJA3mnqpLh3R4/OclMMFEo=" #local.combined_encoded_string
    "APP_LOCALE"                                      = "en"
    "APP_MAINTENANCE_DRIVER"                          = "file"
    "APP_NAME"                                        = "FDD-PROD"
    "APP_TIMEZONE"                                    = "UTC"
    "APP_URL"                                         = lower("https://${var.app_service_name}-${var.resource_suffix}.azurewebsites.net")
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "8b775591-2ef7-400a-8880-8861b4049914"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = "InstrumentationKey=8b775591-2ef7-400a-8880-8861b4049914;IngestionEndpoint=https://uaenorth-0.in.applicationinsights.azure.com/;LiveEndpoint=https://uaenorth.livediagnostics.monitor.azure.com/;ApplicationId=e1329731-4fcc-4494-aca1-402a313757a6"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "AWS_ACCESS_KEY_ID"                               = ""
    "AWS_BUCKET"                                      = ""
    "AWS_DEFAULT_REGION"                              = "us-east-1"
    "AWS_SECRET_ACCESS_KEY"                           = ""
    "AWS_USE_PATH_STYLE_ENDPOINT"                     = false
    "AZURE_REDIS_DATABASE"                            = 0
    "AZURE_REDIS_HOST"                                = var.redis_hostname
    "AZURE_REDIS_PASSWORD"                            = var.redis_primary_access_key
    "AZURE_REDIS_PORT"                                = 6379
    "AZURE_REDIS_SSL"                                 = true
    "BCRYPT_ROUNDS"                                   = 12
    "BROADCAST_CONNECTION"                            = "log"
    "CACHE_PREFIX"                                    = ""
    "CACHE_STORE"                                     = "redis"
    "DB_CONNECTION"                                   = "mysql"
    "DB_DATABASE"                                     = "prod-db"
    "DB_HOST"                                         = "${var.mysql_server_name}.mysql.database.azure.com"
    "DB_HOST_READ"                                    = "${var.mysql_server_name}.mysql.database.azure.com"
    "DB_PASSWORD"                                     = var.mysql_server_admin_password
    "DB_PORT"                                         = 3306
    "DB_USERNAME"                                     = var.mysql_server_admin_login
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "FILESYSTEM_DISK"                                 = "local"
    "InstrumentationEngine_EXTENSION_VERSION"         = "disabled"
    "LOG_CHANNEL"                                     = "stack"
    "LOG_DEPRECATIONS_CHANNEL"                        = "null"
    "LOG_LEVEL"                                       = "debug"
    "LOG_STACK"                                       = "single"
    "MAIL_ENCRYPTION"                                 = "tls"
    "MAIL_FROM_ADDRESS"                               = "omp@dub.ai"
    "MAIL_FROM_NAME"                                  = "1 Million Prompters - dub.ai"
    "MAIL_HOST"                                       = "smtp.sendgrid.net"
    "MAIL_MAILER"                                     = "smtp"
    "MAIL_PASSWORD"                                   = "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"
    "MAIL_PORT"                                       = 587
    "MAIL_USERNAME"                                   = "apikey"
    "MEMCACHED_HOST"                                  = "127.0.0.1"
    "QUEUE_CONNECTION"                                = "database"
    "REDIS_CLIENT"                                    = "phpredis"
    "REDIS_HOST"                                      = var.redis_hostname
    "REDIS_PASSWORD"                                  = var.redis_primary_access_key
    "REDIS_PORT"                                      = 6379
    "REDIS_SSL"                                       = true
    "SCM_DO_BUILD_DURING_DEPLOYMENT"                  = true
    "SESSION_DOMAIN"                                  = "null"
    "SESSION_DRIVER"                                  = "database"
    "SESSION_ENCRYPT"                                 = false
    "SESSION_LIFETIME"                                = 120
    "SESSION_PATH"                                    = "/"
    "SnapshotDebugger_EXTENSION_VERSION"              = "disabled"
    "VITE_APP_NAME"                                   = "$${APP_NAME}"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
    "AZURE_STORAGE_ACCOUNT_NAME"                      = var.storage_account_name
    "AZURE_STORAGE_ACCOUNT_KEY"                       = var.storage_account_key
    "AZURE_STORAGE_CONTAINER"                         = var.blob_container_name
    "AZURE_STORAGE_URL"                               = "https://${var.storage_account_name}.blob.core.windows.net/${var.blob_container_name}"
    "DISABLE_HOMEPAGE_REDIRECT"                       = "true"

  }

  depends_on = [azurerm_service_plan.appservice_plan]
}

resource "azurerm_app_service_virtual_network_swift_connection" "appservice-vnet-integration" {
  app_service_id = azurerm_linux_web_app.appservice.id
  subnet_id      = var.subnet_id
}



# # Define the content of the file
# data "template_file" "myfile" {
#   template = <<EOF
# This is the content of my file.
# Hello EveryOne
# You can add any text you want here.
# EOF
# }

# # Write the template data to a local file
# resource "local_file" "myfile" {
#   content  = data.template_file.myfile.rendered
#   filename = "${path.module}/${var.file_name}"  # Using the dynamic filename variable
# }

# # Upload the file to the App Service using Kudu API with PowerShell
# resource "null_resource" "upload_to_app_service" {
#   provisioner "local-exec" {
#     command = <<EOT
#       powershell -Command "
#         # Step 1: Retrieve publishing credentials
#         $publishingCredentials = az webapp deployment list-publishing-credentials --name ${azurerm_linux_web_app.appservice.name} --resource-group "rg-network-dcai-prod-uaen-001" --query '{username: publishingUserName, password: publishingPassword}' -o json | ConvertFrom-Json;
        
#         # Step 2: Extract the username and password
#         $PUBLISHING_USERNAME = $publishingCredentials.username;
#         $PUBLISHING_PASSWORD = $publishingCredentials.password;
        
#         # Step 3: Define the Kudu URL for the file upload
#         $KUDU_URL = \"https://${azurerm_linux_web_app.appservice.name}.scm.azurewebsites.net/api/vfs/home/${var.file_name}\";
        
#         # Step 4: Encode credentials as Base64 for the Authorization header
#         $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(\"$${PUBLISHING_USERNAME}:$${PUBLISHING_PASSWORD}\"));
        
#         # Step 5: Use Invoke-RestMethod to upload the file
#         Invoke-RestMethod -Uri $KUDU_URL -Method Put -Headers @{Authorization=(\"Basic {0}\" -f $base64AuthInfo)} -InFile \"${path.module}/${var.file_name}\" -ContentType \"multipart/form-data\";
#       "
#     EOT
#   }

#   depends_on = [azurerm_linux_web_app.appservice, local_file.myfile]
# }









# # Define a template with dynamic content
# data "template_file" "php_ini" {
#   template = <<EOF
# error_log=/dev/stderr
# display_errors=Off
# log_errors=On
# display_startup_errors=Off
# date.timezone=Asia/Dubai
# memory_limit=256M
# EOF
# }

# # Write the template data to a local file
# resource "local_file" "php_ini_file" {
#   content  = data.template_file.php_ini.rendered
#   filename = "/home/php.ini"
# }

# # Define a template with dynamic content
# data "template_file" "nginx_conf" {
#   template = <<EOF
# user www-data;
# worker_processes auto;
# pid /run/nginx.pid;
# error_log /dev/stderr;
# include /etc/nginx/modules-enabled/*.conf;

# events {
# 	worker_connections 10068;
# 	multi_accept on;
# }

# http {

# 	##
# 	# Basic Settings
# 	##

# 	sendfile on;
# 	tcp_nopush on;
# 	types_hash_max_size 2048;
#         server_names_hash_bucket_size 128;
# 	# server_tokens off;

# 	# server_names_hash_bucket_size 64;
# 	# server_name_in_redirect off;

# 	include /etc/nginx/mime.types;
# 	default_type application/octet-stream;

# 	##
# 	# SSL Settings
# 	##

# 	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
# 	ssl_prefer_server_ciphers on;

# 	##
# 	# Logging Settings
# 	##

# 	access_log off;

# 	##
# 	# Gzip Settings
# 	##

# 	gzip on;

# 	# gzip_vary on;
# 	# gzip_proxied any;
# 	# gzip_comp_level 6;
# 	# gzip_buffers 16 8k;
# 	# gzip_http_version 1.1;
# 	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

# 	##
# 	# Virtual Host Configs
# 	##

# 	include /etc/nginx/conf.d/*.conf;
# 	include /etc/nginx/sites-enabled/*;
# }


# #mail {
# #	# See sample authentication script at:
# #	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
# #
# #	# auth_http localhost/auth.php;
# #	# pop3_capabilities "TOP" "USER";
# #	# imap_capabilities "IMAP4rev1" "UIDPLUS";
# #
# #	server {
# #		listen     localhost:110;
# #		protocol   pop3;
# #		proxy      on;
# #	}
# #
# #	server {
# #		listen     localhost:143;
# #		protocol   imap;
# #		proxy      on;
# #	}
# #}

# EOF
# }

# # Write the template data to a local file
# resource "local_file" "nginx_conf_file" {
#   content  = data.template_file.nginx_conf.rendered
#   filename = "/home/nginx.conf"
# }

# # Define a template with dynamic content
# data "template_file" "laravel_worker_conf" {
#   template = <<EOF
# process_name=%(program_name)s_%(process_num)02d
# command=php /home/site/wwwroot/artisan queue:work --sleep=3 --tries=3 --max-time=3600
# autostart=true
# autorestart=true
# stopasgroup=true
# killasgroup=true
# user=forge
# numprocs=8
# redirect_stderr=true
# stdout_logfile=/home/site/wwwroot/storage/logs/worker.log
# stopwaitsecs=3600
# EOF
# }

# # Write the template data to a local file
# resource "local_file" "laravel_worker_conf_file" {
#   content  = data.template_file.laravel_worker_conf.rendered
#   filename = "/home/laravel-worker.conf"
# }

# # Define a template with dynamic content
# data "template_file" "default_conf" {
#   template = <<EOF
# # nginx default file, name it as "default"
# # check out my YouTube video "https://youtu.be/-PGhVFsOnGA"
# server {
#     #proxy_cache cache;
#         #proxy_cache_valid 200 1s;
#     listen 8080;
#     listen [::]:8080;
#     root /home/site/wwwroot/public;
#     server_name "${azurerm_linux_web_app.appservice.app_settings["APP_URL"]}"; 
#     port_in_redirect off;

#     error_log  /var/log/nginx/example.com.error.log;
#     access_log /var/log/nginx/example.com.access.log;


#     add_header X-Frame-Options "SAMEORIGIN";
#     add_header X-Content-Type-Options "nosniff";
 
#     index index.php;
 
#     charset utf-8;

#     if ($http_x_arr_ssl = "") {
#         return 301 https://$host$request_uri;
#     }
 
#     location / {
#         try_files $uri $uri/ /index.php?$query_string;
#     }
 
#     location = /favicon.ico { access_log off; log_not_found off; }
#     location = /robots.txt  { access_log off; log_not_found off; }
 
#     error_page 404 /index.php;
 
 
#     location ~ /\.(?!well-known).* {
#         deny all;
#     }
    

#     # Add locations of phpmyadmin here.
#     location ~ [^/]\.php(/|$) {
#         fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
#         fastcgi_pass 127.0.0.1:9000;
#         include fastcgi_params;
#         fastcgi_param HTTP_PROXY "";
#         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#         fastcgi_param PATH_INFO $fastcgi_path_info;
#         fastcgi_param QUERY_STRING $query_string;
#         fastcgi_intercept_errors on;
#         fastcgi_connect_timeout         300; 
#         fastcgi_send_timeout           3600; 
#         fastcgi_read_timeout           3600;
#         fastcgi_buffer_size 128k;
#         fastcgi_buffers 4 256k;
#         fastcgi_busy_buffers_size 256k;
#         fastcgi_temp_file_write_size 256k;
#     }
# }
# EOF
# }

# # Write the template data to a local file
# resource "local_file" "default_conf_file" {
#   content  = data.template_file.default_conf.rendered
#   filename = "/home/default.conf"
# }

# # Define a template with dynamic content
# data "template_file" "startup_sh" {
#   template = <<EOF
# # name this file as "startup.sh" and call it from "startup command" as "/home/startup.sh"
# # check out my YouTube video "https://youtu.be/-PGhVFsOnGA"
# cp /home/nginx.conf /etc/nginx/nginx.conf
# cp /home/default.conf /etc/nginx/conf.d/default.conf

# cp /home/php.ini /usr/local/etc/php/conf.d/php.ini

# # install support for webp file conversion
# apt-get update --allow-releaseinfo-change && apt-get install -y libfreetype6-dev \
#                 libjpeg62-turbo-dev \
#                 libpng-dev \
#                 libwebp-dev \
#         && docker-php-ext-configure gd --with-freetype --with-webp  --with-jpeg
# docker-php-ext-install gd

# # install support for queue
# apt-get install -y supervisor telnet redis-tools iputils-ping

# cp /home/laravel-worker.conf /etc/supervisor/conf.d/laravel-worker.conf

# # restart nginx
# service nginx restart
# service supervisor restart


# php /home/site/wwwroot/artisan down --refresh=15 --secret="1630542a-246b-4b66-afa1-dd72a4c43515"

# php /home/site/wwwroot/artisan migrate --force

# # Clear caches
# php /home/site/wwwroot/artisan cache:clear

# # Clear expired password reset tokens
# #php /home/site/wwwroot/artisan auth:clear-resets

# # Clear and cache routes
# php /home/site/wwwroot/artisan route:cache

# # Clear and cache config
# php /home/site/wwwroot/artisan config:cache

# # Clear and cache views
# php /home/site/wwwroot/artisan view:cache

# curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
# apt-get install nsolid -y
# cd /home/site/wwwroot/
# npm install
# npm run build
# # Install node modules
# # npm ci

# # Build assets using Laravel Mix
# # npm run production --silent

# # uncomment next line if you dont have S3 or Blob storage
# #php /home/site/wwwroot/artisan storage:link

# # Turn off maintenance mode
# php /home/site/wwwroot/artisan up

# # run worker
# nohup php /home/site/wwwroot/artisan queue:work &
# EOF
# }

# # Write the template data to a local file
# resource "local_file" "startup_sh_file" {
#   content  = data.template_file.startup_sh.rendered
#   filename = "/home/startup.sh"
# }