<?php

/**
 * The file that defines the core plugin class
 */
class Crux {

    /**
     * The loader that's responsible for maintaining and registering all hooks.
     */
    protected $loader;

    /**
     * The unique identifier of this plugin.
     */
    protected $plugin_name;

    /**
     * The current version of the plugin.
     */
    protected $version;

    /**
     * Define the core functionality of the plugin.
     */
    public function __construct() {
        if (defined('CRUX_CLIMBING_GYM_VERSION')) {
            $this->version = CRUX_CLIMBING_GYM_VERSION;
        } else {
            $this->version = '1.0.0';
        }
        $this->plugin_name = 'crux-climbing-gym';

        $this->load_dependencies();
        $this->set_locale();
        $this->define_admin_hooks();
        $this->define_public_hooks();
        $this->define_api_hooks();
    }

    /**
     * Load the required dependencies for this plugin.
     */
    private function load_dependencies() {
        // The class responsible for orchestrating the actions and filters
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/class-crux-loader.php';

        // The class responsible for defining internationalization functionality
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/class-crux-i18n.php';

        // The class responsible for defining all actions in the admin area
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/class-crux-admin.php';

        // The class responsible for defining all actions for the public-facing side
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'public/class-crux-public.php';

        // The class responsible for the REST API
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/class-crux-api.php';

        // Model classes
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/models/class-crux-route.php';
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/models/class-crux-user.php';
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/models/class-crux-grade.php';
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/models/class-crux-hold-colors.php';
        require_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'includes/models/class-crux-wall-section.php';

        $this->loader = new Crux_Loader();
    }

    /**
     * Define the locale for this plugin for internationalization.
     */
    private function set_locale() {
        $plugin_i18n = new Crux_i18n();
        $this->loader->add_action('plugins_loaded', $plugin_i18n, 'load_plugin_textdomain');
    }

    /**
     * Register all of the hooks related to the admin area functionality.
     */
    private function define_admin_hooks() {
        $plugin_admin = new Crux_Admin($this->get_plugin_name(), $this->get_version());

        $this->loader->add_action('admin_enqueue_scripts', $plugin_admin, 'enqueue_styles');
        $this->loader->add_action('admin_enqueue_scripts', $plugin_admin, 'enqueue_scripts');
        $this->loader->add_action('admin_menu', $plugin_admin, 'add_admin_menu');
        
        // AJAX actions for settings management
        $this->loader->add_action('wp_ajax_crux_add_wall_section', $plugin_admin, 'ajax_add_wall_section');
        $this->loader->add_action('wp_ajax_crux_delete_wall_section', $plugin_admin, 'ajax_delete_wall_section');
        $this->loader->add_action('wp_ajax_crux_add_hold_color', $plugin_admin, 'ajax_add_hold_color');
        $this->loader->add_action('wp_ajax_crux_delete_hold_color', $plugin_admin, 'ajax_delete_hold_color');
        
        // AJAX actions for routes management
        $this->loader->add_action('wp_ajax_crux_rename_route', $plugin_admin, 'ajax_rename_route');
        $this->loader->add_action('wp_ajax_crux_get_route', $plugin_admin, 'ajax_get_route');
        $this->loader->add_action('wp_ajax_crux_update_route', $plugin_admin, 'ajax_update_route');
    }

    /**
     * Register all of the hooks related to the public-facing functionality.
     */
    private function define_public_hooks() {
        $plugin_public = new Crux_Public($this->get_plugin_name(), $this->get_version());

        $this->loader->add_action('wp_enqueue_scripts', $plugin_public, 'enqueue_styles');
        $this->loader->add_action('wp_enqueue_scripts', $plugin_public, 'enqueue_scripts');
        
        // Add shortcodes
        $this->loader->add_action('init', $plugin_public, 'register_shortcodes');
    }

    /**
     * Register all of the hooks related to the REST API.
     */
    private function define_api_hooks() {
        $plugin_api = new Crux_API();

        $this->loader->add_action('rest_api_init', $plugin_api, 'register_routes');
    }

    /**
     * Run the loader to execute all of the hooks with WordPress.
     */
    public function run() {
        $this->loader->run();
    }

    /**
     * The name of the plugin used to uniquely identify it.
     */
    public function get_plugin_name() {
        return $this->plugin_name;
    }

    /**
     * The reference to the class that orchestrates the hooks.
     */
    public function get_loader() {
        return $this->loader;
    }

    /**
     * Retrieve the version number of the plugin.
     */
    public function get_version() {
        return $this->version;
    }
}
