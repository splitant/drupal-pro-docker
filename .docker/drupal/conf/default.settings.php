<?php

// @codingStandardsIgnoreFile

$databases = [];

$config_directories = [];

$settings['hash_salt'] = '';

$settings['update_free_access'] = FALSE;

$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];

$settings['trusted_host_patterns'] = [
  sprintf('^%s$', str_replace('.', '\.', getenv('PROJECT_BASE_URL'))),
];

$settings['reverse_proxy'] = TRUE;
$settings['reverse_proxy_addresses'] = [
  $_SERVER['REMOTE_ADDR']
];

$settings['entity_update_batch_size'] = 50;
$settings['file_private_path'] = '../private';
$settings['file_temp_path'] = '/tmp';

// DEV MODE
if (getenv('ENVIRONMENT') === 'dev') {
  $settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';

  if (file_exists(DRUPAL_ROOT . '/' . $site_path . '/settings.local.php')) {
    include DRUPAL_ROOT . '/' . $site_path . '/settings.local.php';
  }

  $config['config_split.config_split.development']['status'] = TRUE;
}
// STAGING & PROD MODE
else {
  $settings['skip_permissions_hardening'] = TRUE;
  $settings['container_yamls'][] = DRUPAL_ROOT . '/sites/services.yml';
}

$settings['config_sync_directory'] = '../config/sync';

$settings['state_cache'] = TRUE;

// Uncomment the following line as needed.

$config['system.site']['mail'] = 'superadmin@admin.com';

/*
 * Mailer
 */
$config['symfony_mailer.mailer_transport.smtp']['configuration']['port'] = '1025';
$config['symfony_mailer.mailer_transport.smtp']['configuration']['host'] = sprintf('%s_mailhog', getenv('PROJECT_NAME'));
$config['symfony_mailer.mailer_transport.smtp']['configuration']['query']['query_peer'] = TRUE;

/*
 * SOLR
 */
$config['search_api.server.solr']['backend_config']['connector_config']['host'] = sprintf('%s_solr', getenv('PROJECT_NAME'));
$config['search_api.server.solr']['backend_config']['connector_config']['core'] = getenv('SOLR_CORE');
$config['search_api.server.solr']['backend_config']['connector_config']['port'] = '8983';

$databases['default']['default'] = [
  'database' => getenv('DB_NAME'),
  'username' => getenv('DB_USER'),
  'password' => getenv('DB_PASSWORD'),
  'driver' => getenv('DB_DRIVER'),
  'host' => getenv('DB_HOST'),
  'namespace' => sprintf('Drupal\\Core\\Database\\Driver\\%s', getenv('DB_DRIVER')),
  'collation' => 'utf8mb4_general_ci',
  'port' => getenv('DB_PORT'),
  'prefix' => '',
  'init_commands' => [
    'isolation_level' => 'SET SESSION transaction_isolation=\'READ-COMMITTED\'',
  ],
];
