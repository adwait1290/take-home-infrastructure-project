<?php

// Fetch values from Environment Variables
$dbName = getenv('DB_NAME');
$dbUser = getenv('DB_USER');
$dbPassword = getenv('DB_PASSWORD');
$dbHost = getenv('DB_HOST');


// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', $dbName);

/** MySQL database username */
define('DB_USER', $dbUser);

/** MySQL database password */
define('DB_PASSWORD', $dbPassword);

/** MySQL hostname */
define('DB_HOST', $dbHost);

define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

$table_prefix  = 'wp_';


define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

define('WP_MEMORY_LIMIT', '256M');
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');

