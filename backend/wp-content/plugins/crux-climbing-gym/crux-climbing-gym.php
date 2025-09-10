<?php
/**
 * Plugin Name: Crux Climbing Gym Management
 * Plugin URI: https://github.com/arqueffe/crux_gym
 * Description: Comprehensive climbing gym management system with route tracking, user interactions, and performance analytics.
 * Version: 1.0.0
 * Author: Arthur
 * License: MIT
 * Text Domain: crux-climbing-gym
 * Domain Path: /languages
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

/**
 * Currently plugin version.
 */
define('CRUX_CLIMBING_GYM_VERSION', '1.0.0');
define('CRUX_CLIMBING_GYM_PLUGIN_DIR', plugin_dir_path(__FILE__));
define('CRUX_CLIMBING_GYM_PLUGIN_URL', plugin_dir_url(__FILE__));

/**
 * The code that runs during plugin activation.
 */
function activate_crux_climbing_gym() {
    require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/class-crux-activator.php';
    Crux_Activator::activate();
}

/**
 * The code that runs during plugin deactivation.
 */
function deactivate_crux_climbing_gym() {
    require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/class-crux-deactivator.php';
    Crux_Deactivator::deactivate();
}

register_activation_hook(__FILE__, 'activate_crux_climbing_gym');
register_deactivation_hook(__FILE__, 'deactivate_crux_climbing_gym');

/**
 * The core plugin class that is used to define internationalization,
 * admin-specific hooks, and public-facing site hooks.
 */
require CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/class-crux.php';

/**
 * Begins execution of the plugin.
 */
function run_crux_climbing_gym() {
    $plugin = new Crux();
    $plugin->run();
}
run_crux_climbing_gym();
