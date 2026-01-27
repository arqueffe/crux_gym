<?php

/**
 * The admin-specific functionality of the plugin.
 */
class Crux_Admin {

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
     * Register the stylesheets for the admin area.
     */
    public function enqueue_styles() {
        wp_enqueue_style($this->plugin_name, CRUX_CLIMBING_GYM_PLUGIN_URL . 'admin/css/crux-admin.css', array(), $this->version, 'all');
    }

    /**
     * Register the JavaScript for the admin area.
     */
    public function enqueue_scripts() {
        wp_enqueue_script($this->plugin_name, CRUX_CLIMBING_GYM_PLUGIN_URL . 'admin/js/crux-admin.js', array('jquery'), $this->version, false);
        
        // Localize script for AJAX
        wp_localize_script($this->plugin_name, 'crux_admin_ajax', array(
            'ajax_url' => admin_url('admin-ajax.php'),
            'nonce' => wp_create_nonce('crux_admin_nonce')
        ));
    }

    /**
     * Add admin menu pages
     */
    public function add_admin_menu() {
        // Main menu page
        add_menu_page(
            'Crux Climbing Gym',
            'Climbing Gym',
            'manage_options',
            'crux-climbing-gym',
            array($this, 'display_routes_page'),
            'dashicons-location-alt',
            30
        );

        // Routes submenu
        add_submenu_page(
            'crux-climbing-gym',
            'Routes',
            'Routes',
            'edit_posts',
            'crux-climbing-gym',
            array($this, 'display_routes_page')
        );

        // Add Route submenu
        add_submenu_page(
            'crux-climbing-gym',
            'Add Route',
            'Add Route',
            'edit_posts',
            'crux-add-route',
            array($this, 'display_add_route_page')
        );

        // Users submenu
        add_submenu_page(
            'crux-climbing-gym',
            'Climbers',
            'Climbers',
            'manage_options',
            'crux-users',
            array($this, 'display_users_page')
        );

        // Statistics submenu
        add_submenu_page(
            'crux-climbing-gym',
            'Statistics',
            'Statistics',
            'manage_options',
            'crux-statistics',
            array($this, 'display_statistics_page')
        );

        // Settings submenu
        add_submenu_page(
            'crux-climbing-gym',
            'Settings',
            'Settings',
            'manage_options',
            'crux-settings',
            array($this, 'display_settings_page')
        );
    }

    /**
     * Display routes management page
     * Updated to fix lane and color property issues
     */
    public function display_routes_page() {
        global $wpdb;

        // Handle route deletion
        if (isset($_POST['delete_route']) && isset($_POST['route_id'])) {
            check_admin_referer('delete_route_' . $_POST['route_id']);
            $this->delete_route($_POST['route_id']);
            echo '<div class="notice notice-success"><p>Route deleted successfully!</p></div>';
        }

        // Get all routes with details
        $routes = $wpdb->get_results(
            "SELECT r.*, 
                    g.french_name as grade, 
                    g.color as grade_color, 
                    COALESCE(l.number, 0) as lane, 
                    hc.name as color_name, 
                    hc.hex_code as color
             FROM {$wpdb->prefix}crux_routes r
             LEFT JOIN {$wpdb->prefix}crux_grades g ON r.grade_id = g.id
             LEFT JOIN {$wpdb->prefix}crux_lanes l ON r.lane_id = l.id
             LEFT JOIN {$wpdb->prefix}crux_hold_colors hc ON r.hold_color_id = hc.id
             ORDER BY r.created_at DESC"
        );

        // Debug: Check if we have routes and what properties they have
        if (current_user_can('manage_options') && isset($_GET['debug_query'])) {
            echo '<div class="notice notice-info">';
            echo '<p>Debug Query Results:</p>';
            if (!empty($routes)) {
                echo '<pre>' . print_r($routes[0], true) . '</pre>';
            } else {
                echo '<p>No routes found</p>';
            }
            echo '</div>';
        }

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-routes.php';
    }

    /**
     * Display add route page
     */
    public function display_add_route_page() {
        global $wpdb;

        // Handle form submission
        if (isset($_POST['submit'])) {
            check_admin_referer('crux_add_route', 'crux_add_route_nonce');
            $result = $this->create_route($_POST);
            
            if ($result['success']) {
                // Redirect to prevent form resubmission
                $redirect_url = add_query_arg(array(
                    'page' => 'crux-add-route',
                    'route_created' => '1'
                ), admin_url('admin.php'));
                // Cannot use wp_redirect here as header are already sent.
                // wp_redirect($redirect_url);
                // Dirty hack instead for redirection
                echo("<script>location.href = '".$redirect_url."'</script>");
                exit;
            } else {
                // Store error in transient for display after redirect
                set_transient('crux_admin_error', $result['message'], 30);
                $redirect_url = add_query_arg(array(
                    'page' => 'crux-add-route',
                    'error' => '1'
                ), admin_url('admin.php'));
                //wp_redirect($redirect_url);
                echo("<script>location.href = '".$redirect_url."'</script>");
                exit;
            }
        }

        // Show success message after redirect
        if (isset($_GET['route_created']) && $_GET['route_created'] == '1') {
            echo '<div class="notice notice-success is-dismissible"><p>Route created successfully!</p></div>';
        }

        // Show error message after redirect
        if (isset($_GET['error']) && $_GET['error'] == '1') {
            $error_message = get_transient('crux_admin_error');
            if ($error_message) {
                echo '<div class="notice notice-error is-dismissible"><p>Error: ' . esc_html($error_message) . '</p></div>';
                delete_transient('crux_admin_error');
            }
        }

        // Get form data
        $grades = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_grades ORDER BY value ASC");
        $hold_colors = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_hold_colors ORDER BY name ASC");
        $lanes = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_lanes WHERE is_active = 1 ORDER BY id ASC");
        
        // Debug: Check if grades query failed
        if ($wpdb->last_error) {
            echo '<div class="notice notice-error"><p>Database Error: ' . $wpdb->last_error . '</p></div>';
        }
        
        // Debug: Show count for admins
        if (current_user_can('manage_options') && isset($_GET['debug'])) {
            echo '<div class="notice notice-info">';
            echo '<p>Debug Info:</p>';
            echo '<ul>';
            echo '<li>Grades found: ' . count($grades) . '</li>';
            echo '<li>Hold colors found: ' . count($hold_colors) . '</li>';
            echo '<li>Lanes found: ' . count($lanes) . '</li>';
            echo '<li>Grades table: ' . $wpdb->prefix . 'crux_grades</li>';
            echo '</ul>';
            echo '</div>';
        }
        
        // Get wall sections from database
        $wall_sections = Crux_Wall_Section::get_all(true);
        
        // Get distinct route setters from existing routes
        $route_setters = $wpdb->get_col(
            "SELECT DISTINCT route_setter FROM {$wpdb->prefix}crux_routes 
             WHERE route_setter IS NOT NULL AND route_setter != '' 
             ORDER BY route_setter ASC"
        );

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-add-route.php';
    }

    /**
     * Display users page
     */
    public function display_users_page() {
        global $wpdb;

        // Get users with climbing statistics
        $users = $wpdb->get_results(
            "SELECT u.ID, u.user_login, u.user_email, u.user_registered, 
                    um.meta_value as nickname,
                    COALESCE(tick_stats.total_ticks, 0) as total_ticks,
                    COALESCE(like_stats.total_likes, 0) as total_likes
             FROM {$wpdb->users} u
             LEFT JOIN {$wpdb->usermeta} um ON u.ID = um.user_id AND um.meta_key = 'nickname'
             LEFT JOIN (
                 SELECT user_id, COUNT(*) as total_ticks 
                 FROM {$wpdb->prefix}crux_ticks 
                 GROUP BY user_id
             ) tick_stats ON u.ID = tick_stats.user_id
             LEFT JOIN (
                 SELECT user_id, COUNT(*) as total_likes 
                 FROM {$wpdb->prefix}crux_likes 
                 GROUP BY user_id
             ) like_stats ON u.ID = like_stats.user_id
             ORDER BY u.user_registered DESC"
        );

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-users.php';
    }

    /**
     * Display statistics page
     */
    public function display_statistics_page() {
        global $wpdb;

        // Get overall statistics
        $stats = array();
        
        $stats['total_routes'] = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_routes");
        $stats['total_users'] = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->users}");
        $stats['total_ticks'] = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_ticks");
        $stats['total_likes'] = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_likes");
        $stats['total_comments'] = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_comments");

        // Get routes by grade
        $routes_by_grade = $wpdb->get_results(
            "SELECT g.french_name as grade, COUNT(r.id) as count
             FROM {$wpdb->prefix}crux_grades g
             LEFT JOIN {$wpdb->prefix}crux_routes r ON g.id = r.grade_id
             GROUP BY g.id, g.french_name
             ORDER BY g.value ASC"
        );

        // Get most popular routes
        $popular_routes = $wpdb->get_results(
            "SELECT r.name, r.wall_section, g.french_name as grade, 
                    COALESCE(like_counts.likes, 0) as likes,
                    COALESCE(tick_counts.ticks, 0) as ticks
             FROM {$wpdb->prefix}crux_routes r
             LEFT JOIN {$wpdb->prefix}crux_grades g ON r.grade_id = g.id
             LEFT JOIN (
                 SELECT route_id, COUNT(*) as likes 
                 FROM {$wpdb->prefix}crux_likes 
                 GROUP BY route_id
             ) like_counts ON r.id = like_counts.route_id
             LEFT JOIN (
                 SELECT route_id, COUNT(*) as ticks 
                 FROM {$wpdb->prefix}crux_ticks 
                 GROUP BY route_id
             ) tick_counts ON r.id = tick_counts.route_id
             ORDER BY (COALESCE(like_counts.likes, 0) + COALESCE(tick_counts.ticks, 0)) DESC
             LIMIT 10"
        );

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-statistics.php';
    }

    /**
     * Display settings page
     */
    public function display_settings_page() {
        // Handle settings save
        if (isset($_POST['save_settings'])) {
            check_admin_referer('crux_settings');
            
            update_option('crux_gym_name', sanitize_text_field($_POST['gym_name']));
            update_option('crux_enable_public_registration', isset($_POST['enable_public_registration']));
            update_option('crux_routes_per_page', (int)$_POST['routes_per_page']);
            
            echo '<div class="notice notice-success"><p>Settings saved successfully!</p></div>';
        }

        // Get current settings
        $gym_name = get_option('crux_gym_name', 'Crux Climbing Gym');
        $enable_public_registration = get_option('crux_enable_public_registration', true);
        $routes_per_page = get_option('crux_routes_per_page', 20);

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-settings.php';
    }

    /**
     * Create a new route
     */
    private function create_route($data) {
        global $wpdb;

        // Check if unnamed route checkbox is set
        $is_unnamed = isset($data['unnamed_route']) && $data['unnamed_route'] == '1';
        
        // Set route name based on unnamed checkbox
        $route_name = $is_unnamed ? 'Unnamed' : $data['route_name'];
        
        // Validate required fields (route_name is optional if unnamed)
        if (!$is_unnamed && empty($data['route_name'])) {
            return array('success' => false, 'message' => 'Route name is required unless "Leave unnamed" is checked');
        }
        
        if (empty($data['grade_id']) || empty($data['route_setter']) || 
            empty($data['wall_section']) || empty($data['lane_id'])) {
            return array('success' => false, 'message' => 'All required fields must be filled');
        }

        // Validate grade exists
        $grade_exists = $wpdb->get_var($wpdb->prepare(
            "SELECT id FROM {$wpdb->prefix}crux_grades WHERE id = %d", $data['grade_id']
        ));

        if (!$grade_exists) {
            return array('success' => false, 'message' => 'Invalid grade selected');
        }

        // Validate lane exists
        $lane_exists = $wpdb->get_var($wpdb->prepare(
            "SELECT id FROM {$wpdb->prefix}crux_lanes WHERE id = %d", $data['lane_id']
        ));

        if (!$lane_exists) {
            return array('success' => false, 'message' => 'Invalid lane selected');
        }

        // Insert route
        $result = $wpdb->insert(
            $wpdb->prefix . 'crux_routes',
            array(
                'name' => sanitize_text_field($route_name),
                'grade_id' => (int)$data['grade_id'],
                'route_setter' => sanitize_text_field($data['route_setter']),
                'wall_section' => sanitize_text_field($data['wall_section']),
                'lane_id' => (int)$data['lane_id'],
                'hold_color_id' => !empty($data['hold_color_id']) ? (int)$data['hold_color_id'] : null,
                'description' => !empty($data['description']) ? sanitize_textarea_field($data['description']) : null,
                'active' => 1,
                'created_at' => current_time('mysql')
            )
        );

        if ($result === false) {
            return array('success' => false, 'message' => 'Database error: ' . $wpdb->last_error);
        }

        return array('success' => true, 'route_id' => $wpdb->insert_id);
    }

    /**
     * Delete a route and all its associated data
     */
    private function delete_route($route_id) {
        global $wpdb;

        // Delete associated data first (foreign key constraints)
        $wpdb->delete($wpdb->prefix . 'crux_likes', array('route_id' => $route_id));
        $wpdb->delete($wpdb->prefix . 'crux_comments', array('route_id' => $route_id));
        $wpdb->delete($wpdb->prefix . 'crux_grade_proposals', array('route_id' => $route_id));
        $wpdb->delete($wpdb->prefix . 'crux_warnings', array('route_id' => $route_id));
        $wpdb->delete($wpdb->prefix . 'crux_ticks', array('route_id' => $route_id));
        $wpdb->delete($wpdb->prefix . 'crux_projects', array('route_id' => $route_id));

        // Delete the route
        $wpdb->delete($wpdb->prefix . 'crux_routes', array('id' => $route_id));
    }

    /**
     * AJAX handler: Add wall section
     */
    public function ajax_add_wall_section() {
        check_ajax_referer('crux_admin_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $name = sanitize_text_field($_POST['name']);
        $description = isset($_POST['description']) ? sanitize_textarea_field($_POST['description']) : '';
        
        if (empty($name)) {
            wp_send_json_error(array('message' => 'Name is required'));
            return;
        }
        
        $id = Crux_Wall_Section::create(array(
            'name' => $name,
            'description' => $description,
            'sort_order' => 0,
            'is_active' => 1
        ));
        
        if ($id) {
            $section = Crux_Wall_Section::get_by_id($id);
            wp_send_json_success(array(
                'message' => 'Wall section added successfully',
                'section' => $section
            ));
        } else {
            wp_send_json_error(array('message' => 'Failed to add wall section'));
        }
    }

    /**
     * AJAX handler: Delete wall section
     */
    public function ajax_delete_wall_section() {
        check_ajax_referer('crux_admin_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $id = intval($_POST['id']);
        
        if (Crux_Wall_Section::delete($id)) {
            wp_send_json_success(array('message' => 'Wall section deleted successfully'));
        } else {
            wp_send_json_error(array('message' => 'Failed to delete wall section'));
        }
    }

    /**
     * AJAX handler: Add hold color
     */
    public function ajax_add_hold_color() {
        check_ajax_referer('crux_admin_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $name = sanitize_text_field($_POST['name']);
        $hex_code = isset($_POST['hex_code']) ? sanitize_hex_color($_POST['hex_code']) : '';
        
        if (empty($name)) {
            wp_send_json_error(array('message' => 'Name is required'));
            return;
        }
        
        $id = Crux_Hold_Colors::create(array(
            'name' => $name,
            'hex_code' => $hex_code,
            'value' => 0
        ));
        
        if ($id) {
            $color = Crux_Hold_Colors::get_by_id($id);
            wp_send_json_success(array(
                'message' => 'Hold color added successfully',
                'color' => $color
            ));
        } else {
            wp_send_json_error(array('message' => 'Failed to add hold color'));
        }
    }

    /**
     * AJAX handler: Delete hold color
     */
    public function ajax_delete_hold_color() {
        check_ajax_referer('crux_admin_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $id = intval($_POST['id']);
        
        if (Crux_Hold_Colors::delete($id)) {
            wp_send_json_success(array('message' => 'Hold color deleted successfully'));
        } else {
            wp_send_json_error(array('message' => 'Failed to delete hold color'));
        }
    }
    
    /**
     * AJAX handler to rename a route
     */
    public function ajax_rename_route() {
        check_ajax_referer('crux_routes_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $route_id = intval($_POST['route_id']);
        $new_name = sanitize_text_field($_POST['new_name']);
        
        if (empty($new_name)) {
            wp_send_json_error(array('message' => 'Route name cannot be empty'));
            return;
        }
        
        if (Crux_Route::update($route_id, array('name' => $new_name))) {
            wp_send_json_success(array(
                'message' => 'Route renamed successfully',
                'new_name' => $new_name
            ));
        } else {
            wp_send_json_error(array('message' => 'Failed to rename route'));
        }
    }
    
    /**
     * AJAX handler to get route data
     */
    public function ajax_get_route() {
        check_ajax_referer('crux_routes_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $route_id = intval($_POST['route_id']);
        $route = Crux_Route::get_by_id($route_id);
        
        if ($route) {
            wp_send_json_success(array(
                'route' => $route
            ));
        } else {
            wp_send_json_error(array('message' => 'Route not found'));
        }
    }
    
    /**
     * AJAX handler to update a route
     */
    public function ajax_update_route() {
        check_ajax_referer('crux_routes_nonce', 'nonce');
        
        if (!current_user_can('manage_options')) {
            wp_send_json_error(array('message' => 'Unauthorized'));
            return;
        }
        
        $route_id = intval($_POST['route_id']);
        
        $data = array(
            'name' => sanitize_text_field($_POST['name']),
            'grade_id' => intval($_POST['grade_id']),
            'route_setter' => sanitize_text_field($_POST['route_setter']),
            'wall_section' => sanitize_text_field($_POST['wall_section']),
            'lane_id' => intval($_POST['lane_id']),
            'hold_color_id' => !empty($_POST['hold_color_id']) ? intval($_POST['hold_color_id']) : null,
            'description' => sanitize_textarea_field($_POST['description'])
        );
        
        if (Crux_Route::update($route_id, $data)) {
            $route = Crux_Route::get_by_id($route_id);
            wp_send_json_success(array(
                'message' => 'Route updated successfully',
                'route' => $route
            ));
        } else {
            wp_send_json_error(array('message' => 'Failed to update route'));
        }
    }
}
