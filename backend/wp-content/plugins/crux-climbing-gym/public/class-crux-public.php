<?php

/**
 * The public-facing functionality of the plugin.
 */
class Crux_Public {

    /**
     * The ID of this plugin.
     */
    private $plugin_name;

    /**
     * The version of this plugin.
     */
    private $version;

    /**
     * Initialize the class and set its properties.
     */
    public function __construct($plugin_name, $version) {
        $this->plugin_name = $plugin_name;
        $this->version = $version;
    }

    /**
     * Register the stylesheets for the public-facing side of the site.
     */
    public function enqueue_styles() {
        wp_enqueue_style($this->plugin_name, CRUX_CLIMBING_GYM_PLUGIN_URL . 'public/css/crux-public.css', array(), $this->version, 'all');
    }

    /**
     * Register the JavaScript for the public-facing side of the site.
     */
    public function enqueue_scripts() {
        wp_enqueue_script($this->plugin_name, CRUX_CLIMBING_GYM_PLUGIN_URL . 'public/js/crux-public.js', array('jquery'), $this->version, false);
        
        // Localize script for API calls
        wp_localize_script($this->plugin_name, 'crux_public', array(
            'api_url' => home_url('/wp-json/crux/v1/'),
            'nonce' => wp_create_nonce('wp_rest'),
            'user_logged_in' => is_user_logged_in(),
            'current_user_id' => get_current_user_id()
        ));
    }

    /**
     * Register shortcodes
     */
    public function register_shortcodes() {
        add_shortcode('crux_routes_list', array($this, 'routes_list_shortcode'));
        add_shortcode('crux_route_detail', array($this, 'route_detail_shortcode'));
        add_shortcode('crux_user_profile', array($this, 'user_profile_shortcode'));
        add_shortcode('crux_climbing_app', array($this, 'climbing_app_shortcode'));
    }

    /**
     * Routes list shortcode
     */
    public function routes_list_shortcode($atts) {
        $atts = shortcode_atts(array(
            'limit' => 10,
            'wall_section' => '',
            'grade' => '',
            'show_filters' => 'true'
        ), $atts);

        ob_start();
        include CRUX_CLIMBING_GYM_PLUGIN_DIR . 'public/partials/crux-routes-list.php';
        return ob_get_clean();
    }

    /**
     * Route detail shortcode
     */
    public function route_detail_shortcode($atts) {
        $atts = shortcode_atts(array(
            'id' => 0
        ), $atts);

        if (empty($atts['id'])) {
            return '<p>Route ID is required.</p>';
        }

        ob_start();
        include CRUX_CLIMBING_GYM_PLUGIN_DIR . 'public/partials/crux-route-detail.php';
        return ob_get_clean();
    }

    /**
     * User profile shortcode
     */
    public function user_profile_shortcode($atts) {
        if (!is_user_logged_in()) {
            return '<p>Please <a href="' . wp_login_url() . '">login</a> to view your profile.</p>';
        }

        $atts = shortcode_atts(array(
            'user_id' => get_current_user_id()
        ), $atts);

        ob_start();
        include CRUX_CLIMBING_GYM_PLUGIN_DIR . 'public/partials/crux-user-profile.php';
        return ob_get_clean();
    }

    /**
     * Full climbing app shortcode
     */
    public function climbing_app_shortcode($atts) {
        $atts = shortcode_atts(array(
            'theme' => 'light'
        ), $atts);

        ob_start();
        include CRUX_CLIMBING_GYM_PLUGIN_DIR . 'public/partials/crux-climbing-app.php';
        return ob_get_clean();
    }
}
