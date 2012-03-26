<?php

/*
 * Insert User
 *
 * Script will drop all users and associated metadata from WP tables.
 * A default admin user is then inserted.
 *
 * TODO:
 * - wp_insert_user fn lives in different places depending on version of WP
 *   need to test to include correct php script
 *
 * ThemePivot 2012
 * Author: drew@themepivot.com
 *
 */

require_once("wp-load.php");
require_once("wp-includes/version.php");
require_once("wp-includes/rewrite.php");
require_once("wp-admin/includes/misc.php");

global $wp_version;
global $wpdb;
global $wp_rewrite;
global $argv;

// WP install path
$wp_path = realpath($argv[1]);

// WP default admin user
$user_login = "admin";
$user_pass = "password";
$user_role = "administrator";

// WP table names
$user_table = $wpdb->base_prefix . "users";
$usermeta_table = $wpdb->base_prefix . "usermeta";

// Wipe existing users and associated metadata
$wpdb->query("DELETE FROM $user_table");
$wpdb->query("DELETE FROM $usermeta_table");

// Insert new default admin user
if ( !function_exists( 'wp_insert_user' ) )
		include ABSPATH . '/wp-includes/user.php';
wp_insert_user( array ('user_login' => $user_login, 'user_pass' => $user_pass, 'role' => $user_role ) ) ;

// Touch .htaccess
$htaccess = $wp_path . DIRECTORY_SEPARATOR . '.htaccess';
$fp = fopen($htaccess,'w');
fclose($fp);

// Generate .htaccess
$wp_rewrite->init();
//flush_rewrite_rules( true );
//save_mod_rewrite_rules();
$rules = explode( "\n", $wp_rewrite->mod_rewrite_rules() );
insert_with_markers( $htaccess,'WordPress', $rules);

?>
