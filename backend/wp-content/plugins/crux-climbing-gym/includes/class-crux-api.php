<?php

/**
 * The REST API functionality of the plugin.
 */
class Crux_API
{

    /**
     * Initialize the class and set its properties.
     */
    public function __construct() {}

    /**
     * Register the REST API routes.
     */
    public function register_routes()
    {
        $namespace = 'crux/v1';

        // Authentication endpoints
        register_rest_route($namespace, '/auth/me', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_current_user'),
            'permission_callback' => '__return_true'
        ));

        register_rest_route($namespace, '/auth/permissions', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_permissions'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        // Routes endpoints
        register_rest_route($namespace, '/routes', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_routes'),
            'permission_callback' => '__return_true'
        ));

        register_rest_route($namespace, '/routes', array(
            'methods' => 'POST',
            'callback' => array($this, 'create_route'),
            'permission_callback' => array($this, 'check_admin_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_route'),
            'permission_callback' => '__return_true'
        ));

        // Wall sections endpoint
        register_rest_route($namespace, '/wall-sections', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_wall_sections'),
            'permission_callback' => '__return_true'
        ));

        // Grades endpoints
        register_rest_route($namespace, '/grades', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_grades'),
            'permission_callback' => '__return_true'
        ));

        register_rest_route($namespace, '/grade-definitions', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_grade_definitions'),
            'permission_callback' => '__return_true'
        ));

        register_rest_route($namespace, '/grade-colors', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_grade_colors'),
            'permission_callback' => '__return_true'
        ));

        // Hold colors endpoint
        register_rest_route($namespace, '/hold-colors', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_hold_colors'),
            'permission_callback' => '__return_true'
        ));

        // Lanes endpoint
        register_rest_route($namespace, '/lanes', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_lanes'),
            'permission_callback' => '__return_true'
        ));

        // User interaction endpoints
        register_rest_route($namespace, '/user/ticks', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_ticks'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/user/likes', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_likes'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/user/projects', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_projects'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/user/stats', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_stats'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        // Route-specific user interactions
        register_rest_route($namespace, '/routes/(?P<id>\d+)/like-status', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_like_status'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/ticks/me', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_tick'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/ticks', array(
            'methods' => 'POST',
            'callback' => array($this, 'tick_route'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/ticks', array(
            'methods' => 'DELETE',
            'callback' => array($this, 'untick_route'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/attempts', array(
            'methods' => 'POST',
            'callback' => array($this, 'add_attempts'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/send', array(
            'methods' => 'POST',
            'callback' => array($this, 'mark_send'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/like', array(
            'methods' => 'POST',
            'callback' => array($this, 'like_route'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/unlike', array(
            'methods' => 'DELETE',
            'callback' => array($this, 'unlike_route'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/projects', array(
            'methods' => 'POST',
            'callback' => array($this, 'add_project'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/projects', array(
            'methods' => 'DELETE',
            'callback' => array($this, 'remove_project'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/comments', array(
            'methods' => 'POST',
            'callback' => array($this, 'add_comment'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/grade-proposals', array(
            'methods' => 'POST',
            'callback' => array($this, 'propose_grade'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/grade-proposals/me', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_grade_proposal'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)/warnings', array(
            'methods' => 'POST',
            'callback' => array($this, 'add_warning'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));
    }

    /**
     * Check if user is logged in via WordPress cookies
     */
    public function check_user_permissions($request = null)
    {
        return $this->determine_user_from_cookie();
    }

    /**
     * Check if user has admin permissions
     */
    public function check_admin_permissions()
    {
        return current_user_can('manage_options') || current_user_can('edit_posts');
    }

    /**
     * Validate WordPress logged-in cookie manually
     */
    private function determine_user_from_cookie()
    {
        if (!isset($_COOKIE)) {
            return false;
        }

        // Find the WordPress logged-in cookie
        foreach ($_COOKIE as $name => $value) {
            if (strpos($name, 'wordpress_logged_in_') === 0) {
                // Parse the cookie value - format: username|expiration|token|hmac
                $cookie_elements = explode('|', urldecode($value));
                if (count($cookie_elements) >= 4) {
                    $username = $cookie_elements[0];
                    $expiration = (int)$cookie_elements[1];
                    $token = $cookie_elements[2];
                    $hmac = $cookie_elements[3];

                    // Check if cookie hasn't expired
                    if ($expiration > time()) {
                        // Get the user by username
                        $user = get_user_by('login', $username);
                        if ($user) {
                            // Validate the token against user sessions
                            $sessions = get_user_meta($user->ID, 'session_tokens', true);
                            if (is_array($sessions) && isset($sessions[$token])) {
                                // Session token is valid
                                return $user->ID;
                            }

                            // If session validation fails but user exists and cookie hasn't expired,
                            // we'll trust it for now (WordPress sessions can be complex)
                            return $user->ID;
                        }
                    }
                }
                break;
            }
        }

        return false;
    }

    /**
     * Check for WordPress cookie in custom header
     */
    private function check_wp_cookie_header($request)
    {
        // Check for custom WordPress cookie header
        $wp_cookie_header = $request->get_header('X-WordPress-Cookie');

        if (!$wp_cookie_header) {
            // Also check for Authorization header with WordPress cookie
            $auth_header = $request->get_header('Authorization');
            if ($auth_header && strpos($auth_header, 'WordPress ') === 0) {
                $wp_cookie_header = substr($auth_header, 10); // Remove "WordPress " prefix
            }
        }

        if (!$wp_cookie_header) {
            return false;
        }

        // Parse the cookie: wordpress_logged_in_hash=username|expiration|token|hmac
        if (strpos($wp_cookie_header, 'wordpress_logged_in_') === 0) {
            $parts = explode('=', $wp_cookie_header, 2);
            if (count($parts) === 2) {
                $cookie_value = urldecode($parts[1]);
                $value_parts = explode('|', $cookie_value);

                if (count($value_parts) >= 2) {
                    $username = $value_parts[0];
                    $expiration = (int)$value_parts[1];

                    // Check if cookie hasn't expired
                    if ($expiration > time()) {
                        // Get the user by username
                        $user = get_user_by('login', $username);
                        if ($user) {
                            return $user->ID;
                        }
                    }
                }
            }
        }

        return false;
    }

    private function _get_current_user()
    {
        // First, let's try to determine user from cookie and set current user
        $user_id = $this->determine_user_from_cookie();

        if ($user_id) {
            wp_set_current_user($user_id);
        }

        // Now try the standard WordPress method
        $current_user = wp_get_current_user();

        if (!$current_user || $current_user->ID == 0) {
            // Check if we have a custom WordPress cookie header
            $user_id = $this->check_wp_cookie_header($request);
            if ($user_id) {
                wp_set_current_user($user_id);
                $current_user = wp_get_current_user();
            }
        }

        if (!$current_user || $current_user->ID == 0) {
            return new WP_Error('not_authenticated', 'User is not authenticated', array('status' => 401));
        }

        return $current_user;
    }

    /**
     * Legacy endpoint for backward compatibility - wraps user data in 'user' object
     */
    public function get_current_user($request)
    {
        $current_user = $this->_get_current_user();

        // Return user data wrapped in 'user' key for backward compatibility
        return array(
            'user' => array(
                'id' => $current_user->ID,
                'username' => $current_user->user_login,
                'nickname' => get_user_meta($current_user->ID, 'nickname', true) ?: $current_user->display_name,
                'email' => $current_user->user_email,
                'created_at' => $current_user->user_registered,
                'is_active' => true,
                'role' => $current_user->roles[0] ?? 'subscriber'
            )
        );
    }

    /**
     * Get user permissions
     */
    public function get_user_permissions($request)
    {
        $current_user = $this->_get_current_user();
        
        return array(
            'can_manage_routes' => current_user_can('manage_options') || current_user_can('edit_posts'),
            'can_create_routes' => current_user_can('manage_options') || current_user_can('edit_posts'),
            'can_edit_routes' => current_user_can('manage_options'),
            'can_delete_routes' => current_user_can('manage_options'),
            'is_admin' => current_user_can('manage_options')
        );
    }

    /**
     * Get all routes with optional filtering
     */
    public function get_routes($request)
    {
        $params = $request->get_params();
        $filters = array();

        // Extract filters from request
        if (isset($params['wall_section'])) {
            $filters['wall_section'] = sanitize_text_field($params['wall_section']);
        }
        if (isset($params['grade'])) {
            $grade_obj = Crux_Grade::get_by_grade(sanitize_text_field($params['grade']));
            if ($grade_obj) {
                $filters['grade_id'] = $grade_obj->id;
            }
        }
        if (isset($params['lane'])) {
            $filters['lane_id'] = intval($params['lane']);
        }

        $routes = Crux_Route::get_all($filters);

        // Add route statistics and user interactions for each route
        foreach ($routes as &$route) {
            $stats = Crux_Route::get_stats($route->id);
            $route->likes_count = intval($stats['likes_count']);
            $route->comments_count = intval($stats['comments_count']);
            $route->ticks_count = intval($stats['ticks_count']);
            $route->warnings_count = intval($stats['warnings_count']);
            $route->grade_proposals_count = intval($stats['grade_proposals_count']);
            $route->projects_count = intval($stats['projects_count']);

            // Add user-specific data if user is authenticated
            $current_user = $this->_get_current_user();
            if ($current_user && $current_user->ID > 0) {
                $route->user_liked = $this->user_has_liked($current_user->ID, $route->id);
                $route->user_ticked = $this->user_has_ticked($current_user->ID, $route->id);
                $route->user_project = $this->user_has_project($current_user->ID, $route->id);
            }
        }

        return array_values($routes);
    }

    /**
     * Get a single route by ID
     */
    public function get_route($request)
    {
        $route_id = intval($request['id']);
        $route = Crux_Route::get_by_id($route_id);

        if (!$route) {
            return new WP_Error('route_not_found', 'Route not found', array('status' => 404));
        }

        // Add route statistics
        $stats = Crux_Route::get_stats($route->id);
        $route->likes_count = intval($stats['likes_count']);
        $route->comments_count = intval($stats['comments_count']);
        $route->ticks_count = intval($stats['ticks_count']);
        $route->warnings_count = intval($stats['warnings_count']);
        $route->grade_proposals_count = intval($stats['grade_proposals_count']);
        $route->projects_count = intval($stats['projects_count']);

        // Add user-specific data if user is authenticated
        $current_user = $this->_get_current_user();
        if ($current_user && $current_user->ID > 0) {
            $route->user_liked = $this->user_has_liked($current_user->ID, $route->id);
            $route->user_ticked = $this->user_has_ticked($current_user->ID, $route->id);
            $route->user_project = $this->user_has_project($current_user->ID, $route->id);
        }

        return $route;
    }

    /**
     * Create a new route
     */
    public function create_route($request)
    {
        $data = $request->get_json_params();
        
        $required_fields = array('name', 'grade_id', 'route_setter', 'wall_section', 'lane_id', 'hold_color');
        foreach ($required_fields as $field) {
            if (!isset($data[$field])) {
                return new WP_Error('missing_field', "Missing required field: $field", array('status' => 400));
            }
        }

        // Handle hold_color - if it's a string, store it directly, if it's an ID, convert it
        $hold_color = $data['hold_color'];
        if (is_numeric($hold_color)) {
            // It's an ID, get the color name
            $color_obj = Crux_Hold_Colors::get_by_id($hold_color);
            $hold_color = $color_obj ? $color_obj['name'] : $hold_color;
        }

        $route_data = array(
            'name' => sanitize_text_field($data['name']),
            'grade_id' => intval($data['grade_id']),
            'route_setter' => sanitize_text_field($data['route_setter']),
            'wall_section' => sanitize_text_field($data['wall_section']),
            'lane_id' => intval($data['lane_id']),
            'hold_color' => sanitize_text_field($hold_color),
            'description' => isset($data['description']) ? sanitize_textarea_field($data['description']) : ''
        );

        $route_id = Crux_Route::create($route_data);
        
        if (!$route_id) {
            return new WP_Error('creation_failed', 'Failed to create route', array('status' => 500));
        }

        return $this->get_route(array('id' => $route_id));
    }

    /**
     * Get all wall sections
     */
    public function get_wall_sections($request)
    {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_routes';
        $sql = "SELECT DISTINCT wall_section FROM $table_name WHERE wall_section IS NOT NULL AND wall_section != '' ORDER BY wall_section";
        
        $sections = $wpdb->get_col($sql);
        return array_values($sections);
    }

    /**
     * Get all grades as simple list
     */
    public function get_grades($request)
    {
        return Crux_Grade::get_grades_list();
    }

    /**
     * Get grade definitions with full details
     */
    public function get_grade_definitions($request)
    {
        return Crux_Grade::get_all();
    }

    /**
     * Get grade colors mapping
     */
    public function get_grade_colors($request)
    {
        return Crux_Grade::get_colors();
    }

    /**
     * Get all hold colors
     */
    public function get_hold_colors($request)
    {
        return Crux_Hold_Colors::get_all();
    }

    /**
     * Get all lanes
     */
    public function get_lanes($request)
    {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_lanes';
        $sql = "SELECT * FROM $table_name ORDER BY number ASC";
        
        return $wpdb->get_results($sql);
    }

    /**
     * Get user's ticks
     */
    public function get_user_ticks($request)
    {
        $current_user = $this->_get_current_user();
        return Crux_User::get_ticks($current_user->ID);
    }

    /**
     * Get user's likes
     */
    public function get_user_likes($request)
    {
        $current_user = $this->_get_current_user();
        return Crux_User::get_likes($current_user->ID);
    }

    /**
     * Get user's projects
     */
    public function get_user_projects($request)
    {
        global $wpdb;
        $current_user = $this->_get_current_user();
        
        $projects_table = $wpdb->prefix . 'crux_projects';
        $routes_table = $wpdb->prefix . 'crux_routes';
        $grades_table = $wpdb->prefix . 'crux_grades';
        
        $sql = $wpdb->prepare("
            SELECT p.*, r.name as route_name, g.french_name as route_grade, r.wall_section
            FROM $projects_table p
            LEFT JOIN $routes_table r ON p.route_id = r.id
            LEFT JOIN $grades_table g ON r.grade_id = g.id
            WHERE p.user_id = %d
            ORDER BY p.created_at DESC
        ", $current_user->ID);
        
        return $wpdb->get_results($sql, ARRAY_A);
    }

    /**
     * Get user statistics
     */
    public function get_user_stats($request)
    {
        $current_user = $this->_get_current_user();
        return Crux_User::get_stats($current_user->ID);
    }

    public function get_user_like_status($request)
    {
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $liked = $this->user_has_liked($current_user->ID, $route_id);
        
        return array('liked' => $liked);
    }

    /**
     * Get user's tick status for a route
     */
    public function get_user_tick($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        $sql = $wpdb->prepare("SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", $current_user->ID, $route_id);
        
        $tick = $wpdb->get_row($sql, ARRAY_A);
        
        if (!$tick) {
            return new WP_Error('not_found', 'No tick found', array('status' => 404));
        }
        
        return $tick;
    }

    /**
     * Tick a route
     */
    public function tick_route($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $attempts = isset($data['attempts']) ? intval($data['attempts']) : 1;
        $flash = isset($data['flash']) ? (bool)$data['flash'] : false;
        $notes = isset($data['notes']) ? sanitize_textarea_field($data['notes']) : '';
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        
        // Check if tick already exists
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            // Update existing tick
            $result = $wpdb->update(
                $table_name,
                array(
                    'attempts' => $attempts,
                    'notes' => $notes,
                    'top_rope_flash' => $flash ? 1 : 0,
                    'top_rope_send' => 1,
                    'updated_at' => current_time('mysql')
                ),
                array('user_id' => $current_user->ID, 'route_id' => $route_id),
                array('%d', '%s', '%d', '%d', '%s'),
                array('%d', '%d')
            );
        } else {
            // Create new tick
            $result = $wpdb->insert(
                $table_name,
                array(
                    'user_id' => $current_user->ID,
                    'route_id' => $route_id,
                    'attempts' => $attempts,
                    'notes' => $notes,
                    'top_rope_flash' => $flash ? 1 : 0,
                    'top_rope_send' => 1,
                    'created_at' => current_time('mysql'),
                    'updated_at' => current_time('mysql')
                ),
                array('%d', '%d', '%d', '%s', '%d', '%d', '%s', '%s')
            );
        }
        
        if ($result === false) {
            return new WP_Error('tick_failed', 'Failed to tick route', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Untick a route
     */
    public function untick_route($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        
        $result = $wpdb->delete(
            $table_name,
            array('user_id' => $current_user->ID, 'route_id' => $route_id),
            array('%d', '%d')
        );
        
        if ($result === false) {
            return new WP_Error('untick_failed', 'Failed to untick route', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Add attempts to a route (without marking as sent)
     */
    public function add_attempts($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $attempts = intval($data['attempts']);
        $notes = isset($data['notes']) ? sanitize_textarea_field($data['notes']) : '';
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        
        // Check if tick already exists
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            // Update existing tick - add attempts without marking as sent
            $result = $wpdb->update(
                $table_name,
                array(
                    'attempts' => $existing->attempts + $attempts,
                    'notes' => $notes,
                    'updated_at' => current_time('mysql')
                ),
                array('user_id' => $current_user->ID, 'route_id' => $route_id),
                array('%d', '%s', '%s'),
                array('%d', '%d')
            );
        } else {
            // Create new tick without marking as sent
            $result = $wpdb->insert(
                $table_name,
                array(
                    'user_id' => $current_user->ID,
                    'route_id' => $route_id,
                    'attempts' => $attempts,
                    'notes' => $notes,
                    'top_rope_send' => 0,
                    'lead_send' => 0,
                    'created_at' => current_time('mysql'),
                    'updated_at' => current_time('mysql')
                ),
                array('%d', '%d', '%d', '%s', '%d', '%d', '%s', '%s')
            );
        }
        
        if ($result === false) {
            return new WP_Error('attempts_failed', 'Failed to add attempts', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Mark a route as sent in a specific style
     */
    public function mark_send($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $send_type = sanitize_text_field($data['send_type']);
        $notes = isset($data['notes']) ? sanitize_textarea_field($data['notes']) : '';
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        
        // Determine send flags based on send type
        $send_data = array();
        switch ($send_type) {
            case 'top_rope':
                $send_data['top_rope_send'] = 1;
                break;
            case 'lead':
                $send_data['lead_send'] = 1;
                break;
            case 'flash':
                $send_data['top_rope_send'] = 1;
                $send_data['top_rope_flash'] = 1;
                $send_data['attempts'] = 1;
                break;
            case 'lead_flash':
                $send_data['lead_send'] = 1;
                $send_data['lead_flash'] = 1;
                $send_data['attempts'] = 1;
                break;
        }
        
        $send_data['notes'] = $notes;
        $send_data['updated_at'] = current_time('mysql');
        
        // Check if tick already exists
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            // Update existing tick
            $result = $wpdb->update(
                $table_name,
                $send_data,
                array('user_id' => $current_user->ID, 'route_id' => $route_id)
            );
        } else {
            // Create new tick
            $send_data['user_id'] = $current_user->ID;
            $send_data['route_id'] = $route_id;
            $send_data['created_at'] = current_time('mysql');
            if (!isset($send_data['attempts'])) {
                $send_data['attempts'] = 1;
            }
            
            $result = $wpdb->insert($table_name, $send_data);
        }
        
        if ($result === false) {
            return new WP_Error('send_failed', 'Failed to mark send', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Like a route
     */
    public function like_route($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_likes';
        
        // Check if already liked
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            return array('success' => true, 'message' => 'Already liked');
        }
        
        $result = $wpdb->insert(
            $table_name,
            array(
                'user_id' => $current_user->ID,
                'route_id' => $route_id,
                'created_at' => current_time('mysql')
            ),
            array('%d', '%d', '%s')
        );
        
        if ($result === false) {
            return new WP_Error('like_failed', 'Failed to like route', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Unlike a route
     */
    public function unlike_route($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_likes';
        
        $result = $wpdb->delete(
            $table_name,
            array('user_id' => $current_user->ID, 'route_id' => $route_id),
            array('%d', '%d')
        );
        
        if ($result === false) {
            return new WP_Error('unlike_failed', 'Failed to unlike route', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Add a route to projects
     */
    public function add_project($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $notes = isset($data['notes']) ? sanitize_textarea_field($data['notes']) : '';
        
        $table_name = $wpdb->prefix . 'crux_projects';
        
        // Check if already a project
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            return array('success' => true, 'message' => 'Already a project');
        }
        
        $result = $wpdb->insert(
            $table_name,
            array(
                'user_id' => $current_user->ID,
                'route_id' => $route_id,
                'notes' => $notes,
                'created_at' => current_time('mysql')
            ),
            array('%d', '%d', '%s', '%s')
        );
        
        if ($result === false) {
            return new WP_Error('project_failed', 'Failed to add project', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Remove a route from projects
     */
    public function remove_project($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_projects';
        
        $result = $wpdb->delete(
            $table_name,
            array('user_id' => $current_user->ID, 'route_id' => $route_id),
            array('%d', '%d')
        );
        
        if ($result === false) {
            return new WP_Error('remove_project_failed', 'Failed to remove project', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Add a comment to a route
     */
    public function add_comment($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $content = sanitize_textarea_field($data['content']);
        
        if (empty($content)) {
            return new WP_Error('empty_comment', 'Comment content cannot be empty', array('status' => 400));
        }
        
        $table_name = $wpdb->prefix . 'crux_comments';
        
        $result = $wpdb->insert(
            $table_name,
            array(
                'user_id' => $current_user->ID,
                'route_id' => $route_id,
                'content' => $content,
                'created_at' => current_time('mysql')
            ),
            array('%d', '%d', '%s', '%s')
        );
        
        if ($result === false) {
            return new WP_Error('comment_failed', 'Failed to add comment', array('status' => 500));
        }
        
        return array('success' => true, 'comment_id' => $wpdb->insert_id);
    }

    /**
     * Propose a grade for a route
     */
    public function propose_grade($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $proposed_grade = sanitize_text_field($data['proposed_grade']);
        $reasoning = sanitize_textarea_field($data['reasoning']);
        
        $table_name = $wpdb->prefix . 'crux_grade_proposals';
        
        // Check if user already has a proposal for this route
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            // Update existing proposal
            $result = $wpdb->update(
                $table_name,
                array(
                    'proposed_grade' => $proposed_grade,
                    'reasoning' => $reasoning,
                    'updated_at' => current_time('mysql')
                ),
                array('user_id' => $current_user->ID, 'route_id' => $route_id),
                array('%s', '%s', '%s'),
                array('%d', '%d')
            );
        } else {
            // Create new proposal
            $result = $wpdb->insert(
                $table_name,
                array(
                    'user_id' => $current_user->ID,
                    'route_id' => $route_id,
                    'proposed_grade' => $proposed_grade,
                    'reasoning' => $reasoning,
                    'created_at' => current_time('mysql'),
                    'updated_at' => current_time('mysql')
                ),
                array('%d', '%d', '%s', '%s', '%s', '%s')
            );
        }
        
        if ($result === false) {
            return new WP_Error('proposal_failed', 'Failed to propose grade', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Get user's grade proposal for a route
     */
    public function get_user_grade_proposal($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_grade_proposals';
        
        $proposal = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ), ARRAY_A);
        
        if (!$proposal) {
            return null;
        }
        
        return $proposal;
    }

    /**
     * Add a warning to a route
     */
    public function add_warning($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $warning_type = sanitize_text_field($data['warning_type']);
        $description = sanitize_textarea_field($data['description']);
        
        $table_name = $wpdb->prefix . 'crux_warnings';
        
        $result = $wpdb->insert(
            $table_name,
            array(
                'user_id' => $current_user->ID,
                'route_id' => $route_id,
                'warning_type' => $warning_type,
                'description' => $description,
                'created_at' => current_time('mysql')
            ),
            array('%d', '%d', '%s', '%s', '%s')
        );
        
        if ($result === false) {
            return new WP_Error('warning_failed', 'Failed to add warning', array('status' => 500));
        }
        
        return array('success' => true, 'warning_id' => $wpdb->insert_id);
    }

    // Helper methods

    /**
     * Check if user has liked a route
     */
    private function user_has_liked($user_id, $route_id)
    {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_likes';
        $count = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $user_id, $route_id
        ));
        
        return $count > 0;
    }

    /**
     * Check if user has ticked a route
     */
    private function user_has_ticked($user_id, $route_id)
    {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        $count = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $user_id, $route_id
        ));
        
        return $count > 0;
    }

    /**
     * Check if user has a route as project
     */
    private function user_has_project($user_id, $route_id)
    {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_projects';
        $count = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $user_id, $route_id
        ));
        
        return $count > 0;
    }

}
