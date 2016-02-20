<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'whatsapp');

/** MySQL database username */
define('DB_USER', 'root');

/** MySQL database password */
define('DB_PASSWORD', 'mysql');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'Rs4|3OxpuV<lh<|Orb#zzdsa9Z5`P+w|=Aw MQo}d{T-LIi9W5Vm{%wO* OvxV)9');
define('SECURE_AUTH_KEY',  'a_Xion~T.kP&Qao@uCrI6,*Y!=t{TxkMv5pVLHRL.K2;Xh+r[sKY7;b+v/#j8y|-');
define('LOGGED_IN_KEY',    'f+nmLwzHhg nfc{@g6VJojtv}4>--|[L)e4Bn2$2D{Wht~x,EvK3gnEWCk^]<!co');
define('NONCE_KEY',        '[rEVD6`9SoV+U[;=j4O6kv)=!g]nnhY9bSQK}|{GV=Jg^I>c189OdnC+&zUQ+fbA');
define('AUTH_SALT',        '_5bAQ*<bw%iY4*`:A|za+42RQ5SZH|e_g%ooDPfK43N1bD,yXoh&WVG7GRHR=gR?');
define('SECURE_AUTH_SALT', 'Ar{-sr[h(2KY!<u+ {E0|Rb>-RV}xhV;F]ZN-rn8EO{+{?W jML2%`|S!tVW !S]');
define('LOGGED_IN_SALT',   '5tj;]z-@iI9_pN|h^Ua%1S<-/;gek[-R6486e+Y+`2l@oM2+@u#iP-T<P0oe#^+!');
define('NONCE_SALT',       'bUfH:|)A@1f[xJ[( KF&p{,M9nOf`1w|-e_xkbKa9tUxU2DAh$k||wESGjU8P5I[');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
