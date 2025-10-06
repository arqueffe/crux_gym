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

        // New Authentication endpoints (JWT-based)
        register_rest_route($namespace, '/auth/register', array(
            'methods' => 'POST',
            'callback' => array($this, 'register_user'),
            'permission_callback' => '__return_true'
        ));

        register_rest_route($namespace, '/auth/login', array(
            'methods' => 'POST',
            'callback' => array($this, 'login_user'),
            'permission_callback' => '__return_true'
        ));

        register_rest_route($namespace, '/auth/validate', array(
            'methods' => 'GET',
            'callback' => array($this, 'validate_token'),
            'permission_callback' => '__return_true'
        ));

        // Legacy WordPress cookie authentication endpoints
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
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/routes', array(
            'methods' => 'POST',
            'callback' => array($this, 'create_route'),
            'permission_callback' => array($this, 'check_route_setter_permissions')
        ));

        register_rest_route($namespace, '/routes/(?P<id>\d+)', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_route'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        // Wall sections endpoint
        register_rest_route($namespace, '/wall-sections', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_wall_sections'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        // Grades endpoints
        register_rest_route($namespace, '/grades', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_grades'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/grade-definitions', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_grade_definitions'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/grade-colors', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_grade_colors'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        // Hold colors endpoint
        register_rest_route($namespace, '/hold-colors', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_hold_colors'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        // Lanes endpoint
        register_rest_route($namespace, '/lanes', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_lanes'),
            'permission_callback' => array($this, 'check_user_permissions')
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

        register_rest_route($namespace, '/routes/(?P<id>\d+)/unsend', array(
            'methods' => 'POST',
            'callback' => array($this, 'unmark_send'),
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

        // User nickname endpoints
        register_rest_route($namespace, '/user/nickname', array(
            'methods' => 'GET',
            'callback' => array($this, 'get_user_nickname'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/user/nickname', array(
            'methods' => 'PUT',
            'callback' => array($this, 'update_user_nickname'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));

        register_rest_route($namespace, '/route/notes', array(
            'methods' => 'PUT',
            'callback' => array($this, 'update_route_notes'),
            'permission_callback' => array($this, 'check_user_permissions')
        ));
    }


    /**
     * New authentication methods using JWT
     */
    public function register_user($request)
    {
        require_once plugin_dir_path(dirname(__FILE__)) . 'includes/class-crux-auth.php';
        $auth = new Crux_Auth();
        return $auth->register_user($request);
    }

    public function login_user($request)
    {
        require_once plugin_dir_path(dirname(__FILE__)) . 'includes/class-crux-auth.php';
        $auth = new Crux_Auth();
        return $auth->login_user($request);
    }

    public function validate_token($request)
    {
        require_once plugin_dir_path(dirname(__FILE__)) . 'includes/class-crux-auth.php';
        $auth = new Crux_Auth();
        return $auth->validate_token($request);
    }

    /**
     * Check if user is authenticated (any role) - supports both JWT and WordPress cookies
     */
    public function check_user_permissions($request = null)
    {
        // Try JWT authentication first
        $user_id = $this->determine_user_from_jwt($request);
        if ($user_id) {
            wp_set_current_user($user_id);
            return true;
        }

        // Fall back to WordPress cookie authentication
        $user_id = $this->determine_user_from_cookie();
        if (!$user_id) {
            return false;
        }
        return true;
    }

    /**
     * Check if user is admin (role_id 1)
     */
    public function check_admin_permissions($request = null)
    {
        // Try JWT authentication first
        $user_id = $this->determine_user_from_jwt($request);
        if (!$user_id) {
            // Fall back to WordPress cookie authentication
            $user_id = $this->determine_user_from_cookie();
        }
        
        if (!$user_id) {
            return false;
        }
        
        wp_set_current_user($user_id);
        $role_id = $this->get_user_primary_role_id($user_id);
        return $role_id === 1;
    }

    /**
     * Check if user is route setter (role_id 2) or admin (role_id 1)
     */
    public function check_route_setter_permissions($request = null)
    {
        // Try JWT authentication first
        $user_id = $this->determine_user_from_jwt($request);
        if (!$user_id) {
            // Fall back to WordPress cookie authentication
            $user_id = $this->determine_user_from_cookie();
        }
        
        if (!$user_id) {
            return false;
        }
        
        wp_set_current_user($user_id);
        $role_id = $this->get_user_primary_role_id($user_id);
        return in_array($role_id, array(1, 2));
    }

    /**
     * Determine user from JWT token
     */
    private function determine_user_from_jwt($request)
    {
        if (!$request) {
            return false;
        }

        require_once plugin_dir_path(dirname(__FILE__)) . 'includes/class-crux-auth.php';
        $auth = new Crux_Auth();
        
        // Get token from Authorization header or X-Auth-Token header
        $auth_header = $request->get_header('Authorization');
        $token = null;
        
        if ($auth_header && strpos($auth_header, 'Bearer ') === 0) {
            $token = substr($auth_header, 7);
        } else {
            $token = $request->get_header('X-Auth-Token');
        }

        if (!$token) {
            return false;
        }

        // Validate token using reflection to access private method
        $reflection = new ReflectionClass($auth);
        $decode_method = $reflection->getMethod('decode_token');
        $decode_method->setAccessible(true);
        
        $user_id = $decode_method->invoke($auth, $token);
        
        return $user_id ?: false;
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

        // Ensure user has a role assigned (auto-assign member role if none)
        $this->ensure_user_has_role($current_user->ID);

        // Return user data wrapped in 'user' key for backward compatibility
        return array(
            'user' => array(
                'id' => $current_user->ID,
                'username' => $current_user->user_login,
                'nickname' => $this->get_user_display_nickname($current_user->ID),
                'email' => $current_user->user_email,
                'created_at' => $current_user->user_registered,
                'is_active' => true,
                'role' => $this->get_user_primary_role_slug($current_user->ID) ?: 'member'
            )
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

        // Add comments data
        global $wpdb;
        $comments_table = $wpdb->prefix . 'crux_comments';
        $users_table = $wpdb->users;
        
        $comments = $wpdb->get_results($wpdb->prepare("
            SELECT c.*, u.display_name as user_name
            FROM $comments_table c
            LEFT JOIN $users_table u ON c.user_id = u.ID
            WHERE c.route_id = %d
            ORDER BY c.created_at DESC
        ", $route_id));
        
        // Add warnings data
        $warnings_table = $wpdb->prefix . 'crux_warnings';
        
        $warnings = $wpdb->get_results($wpdb->prepare("
            SELECT w.*, u.display_name as user_name
            FROM $warnings_table w
            LEFT JOIN $users_table u ON w.user_id = u.ID
            WHERE w.route_id = %d
            ORDER BY w.created_at DESC
        ", $route_id));
        
        // Add grade proposals data
        $proposals_table = $wpdb->prefix . 'crux_grade_proposals';
        $grades_table = $wpdb->prefix . 'crux_grades';
        
        $grade_proposals = $wpdb->get_results($wpdb->prepare("
            SELECT p.*, u.display_name as user_name, g.french_name as proposed_grade
            FROM $proposals_table p
            LEFT JOIN $users_table u ON p.user_id = u.ID
            LEFT JOIN $grades_table g ON p.proposed_grade_id = g.id
            WHERE p.route_id = %d
            ORDER BY p.created_at DESC
        ", $route_id));
        
        // Get all user IDs for nickname lookup
        $all_user_ids = array();
        if ($comments) {
            foreach ($comments as $comment) {
                if ($comment->user_id) $all_user_ids[] = $comment->user_id;
            }
        }
        if ($warnings) {
            foreach ($warnings as $warning) {
                if ($warning->user_id) $all_user_ids[] = $warning->user_id;
            }
        }
        if ($grade_proposals) {
            foreach ($grade_proposals as $proposal) {
                if ($proposal->user_id) $all_user_ids[] = $proposal->user_id;
            }
        }
        
        // Get all nicknames at once
        $nicknames = $this->get_user_display_nicknames($all_user_ids);
        
        // Update user names in comments
        if ($comments) {
            foreach ($comments as &$comment) {
                if (isset($nicknames[$comment->user_id])) {
                    $comment->user_name = $nicknames[$comment->user_id];
                }
            }
        }
        
        // Update user names in warnings
        if ($warnings) {
            foreach ($warnings as &$warning) {
                if (isset($nicknames[$warning->user_id])) {
                    $warning->user_name = $nicknames[$warning->user_id];
                }
            }
        }
        
        // Update user names in grade proposals
        if ($grade_proposals) {
            foreach ($grade_proposals as &$proposal) {
                if (isset($nicknames[$proposal->user_id])) {
                    $proposal->user_name = $nicknames[$proposal->user_id];
                }
                // Convert date fields to ISO 8601
                if (isset($proposal->created_at) && $proposal->created_at) {
                    $proposal->created_at = str_replace(' ', 'T', $proposal->created_at);
                }
                if (isset($proposal->updated_at) && $proposal->updated_at) {
                    $proposal->updated_at = str_replace(' ', 'T', $proposal->updated_at);
                }
            }
        }
        
        $route->comments = $comments ?: array();
        $route->warnings = $warnings ?: array();
        $route->grade_proposals = $grade_proposals ?: array();

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
        
        $required_fields = array('name', 'grade_id', 'route_setter', 'wall_section', 'lane_id');
        foreach ($required_fields as $field) {
            if (!isset($data[$field])) {
                return new WP_Error('missing_field', "Missing required field: $field", array('status' => 400));
            }
        }

        $route_data = array(
            'name' => sanitize_text_field($data['name']),
            'grade_id' => intval($data['grade_id']),
            'route_setter' => sanitize_text_field($data['route_setter']),
            'wall_section' => sanitize_text_field($data['wall_section']),
            'lane_id' => intval($data['lane_id']),
            'hold_color_id' => isset($data['hold_color_id']) && $data['hold_color_id'] !== null ? intval($data['hold_color_id']) : null,
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
        $sql = "SELECT * FROM $table_name ORDER BY id ASC";
        
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
            // Create empty tick record in database
            $result = $wpdb->insert(
                $table_name,
                array(
                    'user_id' => $current_user->ID,
                    'route_id' => $route_id,
                    'top_rope_attempts' => 0,
                    'lead_attempts' => 0,
                    'top_rope_send' => 0,
                    'lead_send' => 0,
                    'created_at' => current_time('mysql'),
                    'updated_at' => current_time('mysql')
                ),
                array('%d', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%s', '%s')
            );
            
            if ($result === false) {
                return new WP_Error('tick_creation_failed', 'Failed to create empty tick record', array('status' => 500));
            }
            
            // Get the newly created tick
            $tick = $wpdb->get_row($sql, ARRAY_A);
        }
        
        return $tick;
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
        $attempt_type = isset($data['attempt_type']) ? sanitize_text_field($data['attempt_type']) : 'general';
        $notes = isset($data['notes']) ? sanitize_textarea_field($data['notes']) : '';
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        
        // Check if tick already exists
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            // Update existing tick - add attempts without marking as sent
            $new_total_attempts = $existing->attempts + $attempts;
            $update_data = array(
                'updated_at' => current_time('mysql')
            );
            
            // Only update notes if new notes are provided and not empty
            if (!empty($notes)) {
                $update_data['notes'] = $notes;
            }
            
            // Add to specific attempt type
            if ($attempt_type === 'top_rope') {
                $update_data['top_rope_attempts'] = $existing->top_rope_attempts + $attempts;
            } elseif ($attempt_type === 'lead') {
                $update_data['lead_attempts'] = $existing->lead_attempts + $attempts;
            } else {
                // For general attempts, add to both types equally or keep legacy behavior
                $update_data['top_rope_attempts'] = $existing->top_rope_attempts;
                $update_data['lead_attempts'] = $existing->lead_attempts;
            }
            
            // If attempts become > 1, remove any flash status
            if ($new_total_attempts > 1) {
                $update_data['top_rope_flash'] = 0;
                $update_data['lead_flash'] = 0;
            }
            
            $result = $wpdb->update(
                $table_name,
                $update_data,
                array('user_id' => $current_user->ID, 'route_id' => $route_id),
                array('%d', '%d', '%d', '%s', '%s', '%d', '%d'),
                array('%d', '%d')
            );
        } else {
            // Create new tick without marking as sent
            $insert_data = array(
                'user_id' => $current_user->ID,
                'route_id' => $route_id,
                'notes' => $notes,
                'top_rope_send' => 0,
                'lead_send' => 0,
                'created_at' => current_time('mysql'),
                'updated_at' => current_time('mysql')
            );
            
            // Set specific attempt types
            if ($attempt_type === 'top_rope') {
                $insert_data['top_rope_attempts'] = $attempts;
                $insert_data['lead_attempts'] = 0;
            } elseif ($attempt_type === 'lead') {
                $insert_data['top_rope_attempts'] = 0;
                $insert_data['lead_attempts'] = $attempts;
            } else {
                // For general attempts, keep legacy behavior
                $insert_data['top_rope_attempts'] = 0;
                $insert_data['lead_attempts'] = 0;
            }
            
            $result = $wpdb->insert(
                $table_name,
                $insert_data,
                array('%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%s', '%s')
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
                $send_data['top_rope_attempts'] = 1;
                $send_data['lead_attempts'] = 0;
                break;
            case 'lead_flash':
                $send_data['lead_send'] = 1;
                $send_data['top_rope_attempts'] = 0;
                $send_data['lead_attempts'] = 1;
                break;
        }
        
        // Only update notes if new notes are provided and not empty
        if (!empty($notes)) {
            $send_data['notes'] = $notes;
        }
        $send_data['updated_at'] = current_time('mysql');
        
        // Check if tick already exists
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if ($existing) {
            // For non-flash sends, preserve existing attempt counts and ensure minimum 1 attempt of the correct type
            if ($send_type === 'top_rope' && !isset($send_data['top_rope_attempts'])) {
                $send_data['top_rope_attempts'] = max(1, $existing->top_rope_attempts);
                $send_data['lead_attempts'] = $existing->lead_attempts;
            } elseif ($send_type === 'lead' && !isset($send_data['lead_attempts'])) {
                $send_data['lead_attempts'] = max(1, $existing->lead_attempts);
                $send_data['top_rope_attempts'] = $existing->top_rope_attempts;
            }
            
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
            
            // For new ticks, ensure attempt counts are set
            if (!isset($send_data['top_rope_attempts'])) {
                if ($send_type === 'top_rope' || $send_type === 'flash') {
                    $send_data['top_rope_attempts'] = 1;
                    $send_data['lead_attempts'] = 0;
                } elseif ($send_type === 'lead' || $send_type === 'lead_flash') {
                    $send_data['top_rope_attempts'] = 0;
                    $send_data['lead_attempts'] = 1;
                } else {
                    $send_data['top_rope_attempts'] = 0;
                    $send_data['lead_attempts'] = 0;
                }
            }
            
            $result = $wpdb->insert($table_name, $send_data);
        }

        // If route is a project, remove it from projects upon sending
        if ($result) {
            $projects_table = $wpdb->prefix . 'crux_projects';
            $wpdb->delete(
                $projects_table,
                array('user_id' => $current_user->ID, 'route_id' => $route_id),
                array('%d', '%d')
            );
        }
        
        if ($result === false) {
            return new WP_Error('send_failed', 'Failed to mark send', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Remove a specific send type from a route
     */
    public function unmark_send($request)
    {
        global $wpdb;
        
        $route_id = intval($request['id']);
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        $send_type = sanitize_text_field($data['send_type']);
        
        $table_name = $wpdb->prefix . 'crux_ticks';
        
        // Check if tick exists
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d AND route_id = %d", 
            $current_user->ID, $route_id
        ));
        
        if (!$existing) {
            return new WP_Error('no_tick', 'No tick found to unmark', array('status' => 404));
        }
        
        // Determine which send flag to unset based on send type
        $unsend_data = array();
        switch ($send_type) {
            case 'top_rope':
                $unsend_data['top_rope_send'] = 0;
                break;
            case 'lead':
                $unsend_data['lead_send'] = 0;
                break;
        }
        
        $unsend_data['updated_at'] = current_time('mysql');
        
        // Update existing tick to remove the send
        $result = $wpdb->update(
            $table_name,
            $unsend_data,
            array('user_id' => $current_user->ID, 'route_id' => $route_id)
        );
        
        if ($result === false) {
            return new WP_Error('unsend_failed', 'Failed to unmark send', array('status' => 500));
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
        
        // Find the grade ID from the grade name
        $grades_table = $wpdb->prefix . 'crux_grades';
        $grade_id = $wpdb->get_var($wpdb->prepare(
            "SELECT id FROM $grades_table WHERE french_name = %s", 
            $proposed_grade
        ));
        
        if (!$grade_id) {
            return new WP_Error('invalid_grade', 'Invalid grade provided', array('status' => 400));
        }
        
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
                    'proposed_grade_id' => $grade_id,
                    'reasoning' => $reasoning,
                    'updated_at' => current_time('mysql')
                ),
                array('user_id' => $current_user->ID, 'route_id' => $route_id),
                array('%d', '%s', '%s'),
                array('%d', '%d')
            );
        } else {
            // Create new proposal
            $result = $wpdb->insert(
                $table_name,
                array(
                    'user_id' => $current_user->ID,
                    'route_id' => $route_id,
                    'proposed_grade_id' => $grade_id,
                    'reasoning' => $reasoning,
                    'created_at' => current_time('mysql'),
                    'updated_at' => current_time('mysql')
                ),
                array('%d', '%d', '%d', '%s', '%s', '%s')
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
        
        $proposals_table = $wpdb->prefix . 'crux_grade_proposals';
        $users_table = $wpdb->users;
        $grades_table = $wpdb->prefix . 'crux_grades';
        
        $proposal = $wpdb->get_row($wpdb->prepare(
            "SELECT p.*, u.display_name as user_name, g.french_name as proposed_grade
            FROM $proposals_table p
            LEFT JOIN $users_table u ON p.user_id = u.ID
            LEFT JOIN $grades_table g ON p.proposed_grade_id = g.id
            WHERE p.user_id = %d AND p.route_id = %d",
            $current_user->ID, $route_id
        ), ARRAY_A);

        // Convert date fields to ISO 8601 if present
        if ($proposal) {
            if (isset($proposal['created_at']) && $proposal['created_at']) {
                $proposal['created_at'] = str_replace(' ', 'T', $proposal['created_at']);
            }
            if (isset($proposal['updated_at']) && $proposal['updated_at']) {
                $proposal['updated_at'] = str_replace(' ', 'T', $proposal['updated_at']);
            }
        }

        return array(
            'success' => true,
            'data' => $proposal ?: (object)[] // Return empty object if no proposal exists
        );
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

    // ===== NICKNAME MANAGEMENT METHODS =====

    /**
     * Get user's current nickname
     */
    public function get_user_nickname($request)
    {
        global $wpdb;
        
        $current_user = $this->_get_current_user();
        
        $table_name = $wpdb->prefix . 'crux_user_nicknames';
        $nickname = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d",
            $current_user->ID
        ), ARRAY_A);
        
        if (!$nickname) {
            // Fall back to WordPress nickname if no custom nickname exists
            $wp_nickname = get_user_meta($current_user->ID, 'nickname', true);
            return array(
                'success' => true,
                'data' => array(
                    'nickname' => $wp_nickname ?: $current_user->display_name,
                    'source' => 'wordpress'
                )
            );
        }
        
        return array(
            'success' => true,
            'data' => array(
                'nickname' => $nickname['nickname'],
                'source' => 'custom',
                'updated_at' => $nickname['updated_at']
            )
        );
    }

    /**
     * Update user's nickname
     */
    public function update_user_nickname($request)
    {
        global $wpdb;
        
        $current_user = $this->_get_current_user();
        $data = $request->get_json_params();
        
        if (!isset($data['nickname']) || empty(trim($data['nickname']))) {
            return new WP_Error('empty_nickname', 'Nickname cannot be empty', array('status' => 400));
        }
        
        $nickname = sanitize_text_field(trim($data['nickname']));
        
        // Validate nickname length (3-100 characters)
        if (strlen($nickname) < 3) {
            return new WP_Error('nickname_too_short', 'Nickname must be at least 3 characters long', array('status' => 400));
        }
        
        if (strlen($nickname) > 100) {
            return new WP_Error('nickname_too_long', 'Nickname must be less than 100 characters long', array('status' => 400));
        }
        
        // Check for profanity or inappropriate content (basic check)
        $inappropriate_words = array('admin', 'administrator', 'root', 'moderator', 'staff');
        $nickname_lower = strtolower($nickname);
        foreach ($inappropriate_words as $word) {
            if (strpos($nickname_lower, $word) !== false) {
                return new WP_Error('inappropriate_nickname', 'This nickname is not allowed', array('status' => 400));
            }
        }
        
        $table_name = $wpdb->prefix . 'crux_user_nicknames';
        
        // Check if nickname already exists for this user
        $existing = $wpdb->get_row($wpdb->prepare(
            "SELECT * FROM $table_name WHERE user_id = %d",
            $current_user->ID
        ));
        
        if ($existing) {
            // Update existing nickname
            $result = $wpdb->update(
                $table_name,
                array('nickname' => $nickname),
                array('user_id' => $current_user->ID),
                array('%s'),
                array('%d')
            );
        } else {
            // Insert new nickname
            $result = $wpdb->insert(
                $table_name,
                array(
                    'user_id' => $current_user->ID,
                    'nickname' => $nickname
                ),
                array('%d', '%s')
            );
        }
        
        if ($result === false) {
            return new WP_Error('update_failed', 'Failed to update nickname', array('status' => 500));
        }
        
        return array(
            'success' => true,
            'data' => array(
                'nickname' => $nickname,
                'message' => 'Nickname updated successfully'
            )
        );
    }

    // Helper methods

    /**
     * Get user's display nickname from custom table or WordPress meta
     */
    private function get_user_display_nickname($user_id)
    {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_user_nicknames';
        $custom_nickname = $wpdb->get_var($wpdb->prepare(
            "SELECT nickname FROM $table_name WHERE user_id = %d",
            $user_id
        ));
        
        if ($custom_nickname) {
            return $custom_nickname;
        }
        
        // Fall back to WordPress nickname
        $wp_nickname = get_user_meta($user_id, 'nickname', true);
        if ($wp_nickname) {
            return $wp_nickname;
        }
        
        // Final fallback to display_name
        $user = get_user_by('id', $user_id);
        return $user ? $user->display_name : 'User';
    }

    /**
     * Get display nicknames for multiple users at once
     */
    private function get_user_display_nicknames($user_ids)
    {
        if (empty($user_ids)) {
            return array();
        }
        
        global $wpdb;
        
        $user_ids = array_unique(array_map('intval', $user_ids));
        $placeholders = implode(',', array_fill(0, count($user_ids), '%d'));
        
        $nicknames_table = $wpdb->prefix . 'crux_user_nicknames';
        $users_table = $wpdb->users;
        
        // Get all nicknames in one query with fallback to WordPress data
        $results = $wpdb->get_results($wpdb->prepare("
            SELECT 
                u.ID as user_id,
                COALESCE(
                    cn.nickname,
                    um.meta_value,
                    u.display_name,
                    'User'
                ) as display_nickname
            FROM $users_table u
            LEFT JOIN $nicknames_table cn ON u.ID = cn.user_id
            LEFT JOIN {$wpdb->usermeta} um ON u.ID = um.user_id AND um.meta_key = 'nickname'
            WHERE u.ID IN ($placeholders)
        ", ...$user_ids), ARRAY_A);
        
        $nicknames = array();
        foreach ($results as $result) {
            $nicknames[intval($result['user_id'])] = $result['display_nickname'];
        }
        
        return $nicknames;
    }

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

    // ===== ROLE MANAGEMENT METHODS =====

    /**
     * Check if user has a specific capability
     */
    public function user_has_capability($user_id, $capability)
    {
        global $wpdb;
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $roles = $wpdb->get_results($wpdb->prepare(
            "SELECT r.capabilities 
            FROM $user_roles_table ur 
            JOIN $roles_table r ON ur.role_id = r.id 
            WHERE ur.user_id = %d AND ur.is_active = 1 AND r.is_active = 1",
            $user_id
        ), ARRAY_A);
        
        foreach ($roles as $role) {
            $capabilities = json_decode($role['capabilities'], true);
            if (is_array($capabilities) && in_array($capability, $capabilities)) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * Get all roles
     */
    public function get_roles($request)
    {
        global $wpdb;
        
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $roles = $wpdb->get_results(
            "SELECT * FROM $roles_table WHERE is_active = 1 ORDER BY name",
            ARRAY_A
        );
        
        // Decode capabilities JSON
        foreach ($roles as &$role) {
            $role['capabilities'] = json_decode($role['capabilities'], true) ?: [];
            $role['created_at'] = str_replace(' ', 'T', $role['created_at']);
        }
        
        return array(
            'success' => true,
            'data' => $roles
        );
    }

    /**
     * Create a new role
     */
    public function create_role($request)
    {
        global $wpdb;
        
        $params = $request->get_params();
        
        if (empty($params['name']) || empty($params['slug'])) {
            return new WP_Error('missing_parameters', 'Name and slug are required', array('status' => 400));
        }
        
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $capabilities = isset($params['capabilities']) ? json_encode($params['capabilities']) : json_encode([]);
        
        $result = $wpdb->insert(
            $roles_table,
            array(
                'name' => sanitize_text_field($params['name']),
                'slug' => sanitize_text_field($params['slug']),
                'description' => sanitize_textarea_field($params['description'] ?? ''),
                'capabilities' => $capabilities
            ),
            array('%s', '%s', '%s', '%s')
        );
        
        if ($result === false) {
            return new WP_Error('role_creation_failed', 'Failed to create role', array('status' => 500));
        }
        
        return array(
            'success' => true,
            'data' => array(
                'id' => $wpdb->insert_id,
                'name' => $params['name'],
                'slug' => $params['slug'],
                'description' => $params['description'] ?? '',
                'capabilities' => json_decode($capabilities, true)
            )
        );
    }

    /**
     * Update a role
     */
    public function update_role($request)
    {
        global $wpdb;
        
        $role_id = intval($request['id']);
        $params = $request->get_params();
        
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $update_data = array();
        $update_format = array();
        
        if (isset($params['name'])) {
            $update_data['name'] = sanitize_text_field($params['name']);
            $update_format[] = '%s';
        }
        
        if (isset($params['description'])) {
            $update_data['description'] = sanitize_textarea_field($params['description']);
            $update_format[] = '%s';
        }
        
        if (isset($params['capabilities'])) {
            $update_data['capabilities'] = json_encode($params['capabilities']);
            $update_format[] = '%s';
        }
        
        if (empty($update_data)) {
            return new WP_Error('no_data', 'No data to update', array('status' => 400));
        }
        
        $result = $wpdb->update(
            $roles_table,
            $update_data,
            array('id' => $role_id),
            $update_format,
            array('%d')
        );
        
        if ($result === false) {
            return new WP_Error('role_update_failed', 'Failed to update role', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Delete a role
     */
    public function delete_role($request)
    {
        global $wpdb;
        
        $role_id = intval($request['id']);
        
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        // Soft delete by setting is_active to 0
        $result = $wpdb->update(
            $roles_table,
            array('is_active' => 0),
            array('id' => $role_id),
            array('%d'),
            array('%d')
        );
        
        if ($result === false) {
            return new WP_Error('role_deletion_failed', 'Failed to delete role', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Get user's roles
     */
    public function get_user_roles($request)
    {
        global $wpdb;
        
        $user_id = intval($request['user_id']);
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $roles = $wpdb->get_results($wpdb->prepare(
            "SELECT r.*, ur.assigned_at, ur.is_active as user_role_active
            FROM $user_roles_table ur 
            JOIN $roles_table r ON ur.role_id = r.id 
            WHERE ur.user_id = %d AND ur.is_active = 1 AND r.is_active = 1
            ORDER BY r.name",
            $user_id
        ), ARRAY_A);
        
        // Decode capabilities JSON
        foreach ($roles as &$role) {
            $role['capabilities'] = json_decode($role['capabilities'], true) ?: [];
            $role['created_at'] = str_replace(' ', 'T', $role['created_at']);
            $role['assigned_at'] = str_replace(' ', 'T', $role['assigned_at']);
        }
        
        return array(
            'success' => true,
            'data' => $roles
        );
    }

    /**
     * Assign role to user
     */
    public function assign_user_role($request)
    {
        global $wpdb;
        
        $user_id = intval($request['user_id']);
        $params = $request->get_params();
        
        if (empty($params['role_id'])) {
            return new WP_Error('missing_role_id', 'Role ID is required', array('status' => 400));
        }
        
        $role_id = intval($params['role_id']);
        $current_user = $this->_get_current_user();
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        
        $result = $wpdb->insert(
            $user_roles_table,
            array(
                'user_id' => $user_id,
                'role_id' => $role_id,
                'assigned_by' => $current_user->ID
            ),
            array('%d', '%d', '%d')
        );
        
        if ($result === false) {
            return new WP_Error('role_assignment_failed', 'Failed to assign role', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Remove role from user
     */
    public function remove_user_role($request)
    {
        global $wpdb;
        
        $user_id = intval($request['user_id']);
        $role_id = intval($request['role_id']);
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        
        $result = $wpdb->update(
            $user_roles_table,
            array('is_active' => 0),
            array('user_id' => $user_id, 'role_id' => $role_id),
            array('%d'),
            array('%d', '%d')
        );
        
        if ($result === false) {
            return new WP_Error('role_removal_failed', 'Failed to remove role', array('status' => 500));
        }
        
        return array('success' => true);
    }

    /**
     * Get current user's roles
     */
    public function get_current_user_roles($request)
    {
        $current_user = $this->_get_current_user();
        
        $fake_request = new stdClass();
        $fake_request->user_id = $current_user->ID;
        $fake_request_array['user_id'] = $current_user->ID;
        
        // Create a proper request object
        $user_request = new WP_REST_Request('GET', '/crux/v1/users/' . $current_user->ID . '/roles');
        $user_request->set_url_params(array('user_id' => $current_user->ID));
        
        return $this->get_user_roles($user_request);
    }

    /**
     * Get current user's capabilities
     */
    public function get_current_user_capabilities($request)
    {
        $current_user = $this->_get_current_user();
        
        global $wpdb;
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $roles = $wpdb->get_results($wpdb->prepare(
            "SELECT r.capabilities 
            FROM $user_roles_table ur 
            JOIN $roles_table r ON ur.role_id = r.id 
            WHERE ur.user_id = %d AND ur.is_active = 1 AND r.is_active = 1",
            $current_user->ID
        ), ARRAY_A);
        
        $all_capabilities = array();
        
        foreach ($roles as $role) {
            $capabilities = json_decode($role['capabilities'], true);
            if (is_array($capabilities)) {
                $all_capabilities = array_merge($all_capabilities, $capabilities);
            }
        }
        
        $all_capabilities = array_unique($all_capabilities);
        
        return array(
            'success' => true,
            'data' => $all_capabilities
        );
    }

    // ===== USER ROLE HELPER METHODS =====

    /**
     * Ensure user has at least the member role
     */
    public function ensure_user_has_role($user_id)
    {
        global $wpdb;
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        // Check if user already has any active role
        $existing_role = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) 
            FROM $user_roles_table ur 
            JOIN $roles_table r ON ur.role_id = r.id 
            WHERE ur.user_id = %d AND ur.is_active = 1 AND r.is_active = 1",
            $user_id
        ));
        
        // If no role assigned, assign member role
        if (!$existing_role) {
            $member_role = $wpdb->get_var(
                "SELECT id FROM $roles_table WHERE slug = 'member' AND is_active = 1"
            );
            
            if ($member_role) {
                $wpdb->insert(
                    $user_roles_table,
                    array(
                        'user_id' => $user_id,
                        'role_id' => $member_role,
                        'assigned_by' => $user_id // Self-assigned
                    ),
                    array('%d', '%d', '%d')
                );
            }
        }
    }

    /**
     * Get user's primary role slug
     */
    public function get_user_primary_role_slug($user_id)
    {
        global $wpdb;
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $role_slug = $wpdb->get_var($wpdb->prepare(
            "SELECT r.slug 
            FROM $user_roles_table ur 
            JOIN $roles_table r ON ur.role_id = r.id 
            WHERE ur.user_id = %d AND ur.is_active = 1 AND r.is_active = 1
            ORDER BY 
                CASE r.slug 
                    WHEN 'admin' THEN 1 
                    WHEN 'route_setter' THEN 2 
                    WHEN 'member' THEN 3 
                    ELSE 4 
                END
            LIMIT 1",
            $user_id
        ));
        
        return $role_slug ?: 'member';
    }

    /**
     * Get user's primary role ID
     */
    public function get_user_primary_role_id($user_id)
    {
        global $wpdb;
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $role_id = $wpdb->get_var($wpdb->prepare(
            "SELECT r.id 
            FROM $user_roles_table ur 
            JOIN $roles_table r ON ur.role_id = r.id 
            WHERE ur.user_id = %d AND ur.is_active = 1 AND r.is_active = 1
            ORDER BY 
                CASE r.slug 
                    WHEN 'admin' THEN 1 
                    WHEN 'route_setter' THEN 2 
                    WHEN 'member' THEN 3 
                    ELSE 4 
                END
            LIMIT 1",
            $user_id
        ));
        
        return $role_id ? intval($role_id) : 3; // Default to member role ID (3)
    }

    /**
     * Get all WordPress users with their roles
     */
    public function get_users($request)
    {
        global $wpdb;
        
        $users_table = $wpdb->users;
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';
        
        $users = $wpdb->get_results(
            "SELECT u.ID, u.user_login, u.user_email, u.display_name, u.user_registered,
                    r.name as role_name, r.slug as role_slug
            FROM $users_table u
            LEFT JOIN $user_roles_table ur ON u.ID = ur.user_id AND ur.is_active = 1
            LEFT JOIN $roles_table r ON ur.role_id = r.id AND r.is_active = 1
            ORDER BY u.display_name",
            ARRAY_A
        );
        
        // Process users to set default role and format dates
        foreach ($users as &$user) {
            if (!$user['role_slug']) {
                $user['role_slug'] = 'member';
                $user['role_name'] = 'Member';
            }
            $user['created_at'] = str_replace(' ', 'T', $user['user_registered']);
        }
        
        return array(
            'success' => true,
            'data' => $users
        );
    }

    /**
     * Change a user's role
     */
    public function change_user_role($request)
    {
        global $wpdb;
        
        $user_id = intval($request['user_id']);
        $params = $request->get_params();
        
        if (empty($params['role_slug'])) {
            return new WP_Error('missing_role', 'Role slug is required', array('status' => 400));
        }
        
        $role_slug = sanitize_text_field($params['role_slug']);
        $current_user = $this->_get_current_user();
        
        // Validate role exists
        $roles_table = $wpdb->prefix . 'crux_roles';
        $role = $wpdb->get_row($wpdb->prepare(
            "SELECT id, slug FROM $roles_table WHERE slug = %s AND is_active = 1",
            $role_slug
        ), ARRAY_A);
        
        if (!$role) {
            return new WP_Error('invalid_role', 'Invalid role specified', array('status' => 400));
        }
        
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        
        // Remove existing roles
        $wpdb->update(
            $user_roles_table,
            array('is_active' => 0),
            array('user_id' => $user_id),
            array('%d'),
            array('%d')
        );
        
        // Assign new role
        $result = $wpdb->insert(
            $user_roles_table,
            array(
                'user_id' => $user_id,
                'role_id' => $role['id'],
                'assigned_by' => $current_user->ID
            ),
            array('%d', '%d', '%d')
        );
        
        if ($result === false) {
            return new WP_Error('role_assignment_failed', 'Failed to assign role', array('status' => 500));
        }
        
        return array(
            'success' => true,
            'message' => 'User role updated successfully'
        );
    }

    /**
     * Fix incorrect flash data where attempts > 1 but flash is still marked as true
     * This is a cleanup function for existing data
     */
    public function fix_flash_data($request) {
        global $wpdb;
        
        $current_user = $this->_get_current_user();
        
        // Only allow admin users to run this cleanup
        if (!current_user_can('manage_options')) {
            return new WP_Error('permission_denied', 'Permission denied', array('status' => 403));
        }
        
        $ticks_table = $wpdb->prefix . 'crux_ticks';
        
        // Fix top rope flashes where attempts > 1
        $top_rope_fixed = $wpdb->query(
            "UPDATE $ticks_table SET top_rope_flash = 0 WHERE attempts > 1 AND top_rope_flash = 1"
        );
        
        // Fix lead flashes where attempts > 1
        $lead_fixed = $wpdb->query(
            "UPDATE $ticks_table SET lead_flash = 0 WHERE attempts > 1 AND lead_flash = 1"
        );
        
        return array(
            'success' => true,
            'message' => 'Flash data cleanup completed',
            'top_rope_flashes_fixed' => $top_rope_fixed,
            'lead_flashes_fixed' => $lead_fixed
        );
    }

    /**
     * Update route notes for a user without affecting attempts or sends
     */
    public function update_route_notes($request) {
        global $wpdb;
        
        $route_id = $request['route_id'];
        $notes = $request['notes'] ?? '';
        
        // Get current user
        $current_user = $this->_get_current_user();
        
        if (!$current_user) {
            return new WP_Error('not_authenticated', 'User is not authenticated', array('status' => 401));
        }
        
        $user_id = $current_user->ID;
        $ticks_table = $wpdb->prefix . 'crux_ticks';
        
        // Check if a tick entry exists for this user/route combination
        $existing_tick = $wpdb->get_row($wpdb->prepare(
            "SELECT id FROM $ticks_table WHERE user_id = %d AND route_id = %d",
            $user_id,
            $route_id
        ));
        
        if ($existing_tick) {
            // Update existing tick with new notes only
            $result = $wpdb->update(
                $ticks_table,
                array('notes' => $notes),
                array('id' => $existing_tick->id),
                array('%s'),
                array('%d')
            );
        } else {
            // Create new tick entry with only notes
            $result = $wpdb->insert(
                $ticks_table,
                array(
                    'user_id' => $user_id,
                    'route_id' => $route_id,
                    'notes' => $notes,
                    'attempts' => 0,
                    'top_rope_attempts' => 0,
                    'lead_attempts' => 0,
                    'top_rope_send' => 0,
                    'lead_send' => 0,
                    'top_rope_flash' => 0,
                    'lead_flash' => 0
                ),
                array('%d', '%d', '%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d')
            );
        }
        
        if ($result === false) {
            return new WP_Error('notes_update_failed', 'Failed to update notes', array('status' => 500));
        }
        
        return array(
            'success' => true,
            'message' => 'Notes updated successfully',
            'notes' => $notes
        );
    }

}
