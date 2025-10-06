<?php

/**
 * Custom authentication handler for the plugin
 * Provides JWT-based authentication as an alternative to WordPress cookies
 */
class Crux_Auth
{
    private $secret_key;

    public function __construct()
    {
        // Use WordPress secret key or define a custom one
        $this->secret_key = defined('AUTH_KEY') ? AUTH_KEY : 'crux-climbing-gym-secret-key';
    }

    /**
     * Register new user
     */
    public function register_user($request)
    {
        $params = $request->get_json_params();

        // Validate required fields
        if (empty($params['email']) || empty($params['username']) || empty($params['password'])) {
            return new WP_Error(
                'missing_fields',
                'Email, username, and password are required',
                array('status' => 400)
            );
        }

        $email = sanitize_email($params['email']);
        $username = sanitize_user($params['username']);
        $password = $params['password'];

        // Validate email
        if (!is_email($email)) {
            return new WP_Error('invalid_email', 'Invalid email address', array('status' => 400));
        }

        // Validate username
        if (strlen($username) < 3) {
            return new WP_Error(
                'invalid_username',
                'Username must be at least 3 characters',
                array('status' => 400)
            );
        }

        // Validate password
        if (strlen($password) < 6) {
            return new WP_Error(
                'invalid_password',
                'Password must be at least 6 characters',
                array('status' => 400)
            );
        }

        // Check if username exists
        if (username_exists($username)) {
            return new WP_Error('username_exists', 'Username already exists', array('status' => 409));
        }

        // Check if email exists
        if (email_exists($email)) {
            return new WP_Error('email_exists', 'Email already exists', array('status' => 409));
        }

        // Create WordPress user
        $user_id = wp_create_user($username, $password, $email);

        if (is_wp_error($user_id)) {
            return new WP_Error(
                'registration_failed',
                $user_id->get_error_message(),
                array('status' => 500)
            );
        }

        // Set default nickname
        $nickname = !empty($params['nickname']) ? sanitize_text_field($params['nickname']) : $username;
        update_user_meta($user_id, 'nickname', $nickname);

        // Assign default member role (role_id 3)
        global $wpdb;
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        
        $wpdb->insert(
            $user_roles_table,
            array(
                'user_id' => $user_id,
                'role_id' => 3, // Member role
                'assigned_at' => current_time('mysql')
            ),
            array('%d', '%d', '%s')
        );

        // Also create entry in nicknames table
        $nicknames_table = $wpdb->prefix . 'crux_user_nicknames';
        $wpdb->insert(
            $nicknames_table,
            array(
                'user_id' => $user_id,
                'nickname' => $nickname,
                'created_at' => current_time('mysql'),
                'updated_at' => current_time('mysql')
            ),
            array('%d', '%s', '%s', '%s')
        );

        // Generate JWT token
        $token = $this->generate_token($user_id);

        // Get user data
        $user = get_userdata($user_id);

        return array(
            'success' => true,
            'message' => 'User registered successfully',
            'token' => $token,
            'user' => array(
                'id' => $user_id,
                'username' => $user->user_login,
                'nickname' => $nickname,
                'email' => $user->user_email,
                'created_at' => $user->user_registered,
                'is_active' => true,
                'role' => 'member'
            )
        );
    }

    /**
     * Login user
     */
    public function login_user($request)
    {
        $params = $request->get_json_params();

        // Validate required fields
        if (empty($params['username']) || empty($params['password'])) {
            return new WP_Error(
                'missing_credentials',
                'Username and password are required',
                array('status' => 400)
            );
        }

        $username = sanitize_user($params['username']);
        $password = $params['password'];

        // Try to authenticate with username or email
        $user = get_user_by('login', $username);
        if (!$user) {
            $user = get_user_by('email', $username);
        }

        if (!$user) {
            return new WP_Error('invalid_credentials', 'Invalid username or password', array('status' => 401));
        }

        // Check password
        if (!wp_check_password($password, $user->user_pass, $user->ID)) {
            return new WP_Error('invalid_credentials', 'Invalid username or password', array('status' => 401));
        }

        // Ensure user has a role (auto-assign member if none)
        $this->ensure_user_has_role($user->ID);

        // Generate JWT token
        $token = $this->generate_token($user->ID);

        // Get user's display nickname
        $nickname = $this->get_user_display_nickname($user->ID);
        $role = $this->get_user_primary_role_slug($user->ID);

        return array(
            'success' => true,
            'message' => 'Login successful',
            'token' => $token,
            'user' => array(
                'id' => $user->ID,
                'username' => $user->user_login,
                'nickname' => $nickname,
                'email' => $user->user_email,
                'created_at' => $user->user_registered,
                'is_active' => true,
                'role' => $role ?: 'member'
            )
        );
    }

    /**
     * Validate JWT token and return user
     */
    public function validate_token($request)
    {
        $token = $this->get_token_from_request($request);

        if (!$token) {
            return new WP_Error('no_token', 'No authentication token provided', array('status' => 401));
        }

        $user_id = $this->decode_token($token);

        if (!$user_id) {
            return new WP_Error('invalid_token', 'Invalid or expired token', array('status' => 401));
        }

        $user = get_userdata($user_id);

        if (!$user) {
            return new WP_Error('user_not_found', 'User not found', array('status' => 404));
        }

        $nickname = $this->get_user_display_nickname($user->ID);
        $role = $this->get_user_primary_role_slug($user->ID);

        return array(
            'success' => true,
            'user' => array(
                'id' => $user->ID,
                'username' => $user->user_login,
                'nickname' => $nickname,
                'email' => $user->user_email,
                'created_at' => $user->user_registered,
                'is_active' => true,
                'role' => $role ?: 'member'
            )
        );
    }

    /**
     * Generate JWT token
     */
    private function generate_token($user_id)
    {
        $issued_at = time();
        $expiration = $issued_at + (60 * 60 * 24 * 7); // 7 days

        $payload = array(
            'user_id' => $user_id,
            'iat' => $issued_at,
            'exp' => $expiration
        );

        return $this->jwt_encode($payload);
    }

    /**
     * Decode JWT token
     */
    private function decode_token($token)
    {
        $payload = $this->jwt_decode($token);

        if (!$payload || !isset($payload['user_id']) || !isset($payload['exp'])) {
            return false;
        }

        // Check if token is expired
        if ($payload['exp'] < time()) {
            return false;
        }

        return $payload['user_id'];
    }

    /**
     * Get token from request
     */
    private function get_token_from_request($request)
    {
        // Check Authorization header
        $auth_header = $request->get_header('Authorization');
        if ($auth_header && strpos($auth_header, 'Bearer ') === 0) {
            return substr($auth_header, 7);
        }

        // Check custom X-Auth-Token header
        $token_header = $request->get_header('X-Auth-Token');
        if ($token_header) {
            return $token_header;
        }

        return null;
    }

    /**
     * Simple JWT encode
     */
    private function jwt_encode($payload)
    {
        $header = array('alg' => 'HS256', 'typ' => 'JWT');
        
        $segments = array();
        $segments[] = $this->base64url_encode(json_encode($header));
        $segments[] = $this->base64url_encode(json_encode($payload));
        
        $signing_input = implode('.', $segments);
        $signature = hash_hmac('sha256', $signing_input, $this->secret_key, true);
        $segments[] = $this->base64url_encode($signature);
        
        return implode('.', $segments);
    }

    /**
     * Simple JWT decode
     */
    private function jwt_decode($jwt)
    {
        $segments = explode('.', $jwt);
        
        if (count($segments) !== 3) {
            return false;
        }
        
        list($header_b64, $payload_b64, $signature_b64) = $segments;
        
        // Verify signature
        $signing_input = $header_b64 . '.' . $payload_b64;
        $signature = $this->base64url_decode($signature_b64);
        $expected_signature = hash_hmac('sha256', $signing_input, $this->secret_key, true);
        
        if ($signature !== $expected_signature) {
            return false;
        }
        
        $payload = json_decode($this->base64url_decode($payload_b64), true);
        
        return $payload;
    }

    /**
     * Base64 URL encode
     */
    private function base64url_encode($data)
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    /**
     * Base64 URL decode
     */
    private function base64url_decode($data)
    {
        return base64_decode(strtr($data, '-_', '+/'));
    }

    /**
     * Ensure user has a role assigned
     */
    private function ensure_user_has_role($user_id)
    {
        global $wpdb;
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';

        $existing_role = $wpdb->get_var($wpdb->prepare(
            "SELECT role_id FROM $user_roles_table WHERE user_id = %d LIMIT 1",
            $user_id
        ));

        if (!$existing_role) {
            // Assign default member role (role_id 3)
            $wpdb->insert(
                $user_roles_table,
                array(
                    'user_id' => $user_id,
                    'role_id' => 3,
                    'assigned_at' => current_time('mysql')
                ),
                array('%d', '%d', '%s')
            );
        }
    }

    /**
     * Get user's display nickname
     */
    private function get_user_display_nickname($user_id)
    {
        global $wpdb;
        $nicknames_table = $wpdb->prefix . 'crux_user_nicknames';

        $nickname = $wpdb->get_var($wpdb->prepare(
            "SELECT nickname FROM $nicknames_table WHERE user_id = %d",
            $user_id
        ));

        if ($nickname) {
            return $nickname;
        }

        $user = get_userdata($user_id);
        return $user ? $user->user_login : 'User';
    }

    /**
     * Get user's primary role slug
     */
    private function get_user_primary_role_slug($user_id)
    {
        global $wpdb;
        $user_roles_table = $wpdb->prefix . 'crux_user_roles';
        $roles_table = $wpdb->prefix . 'crux_roles';

        $role_slug = $wpdb->get_var($wpdb->prepare(
            "SELECT r.slug FROM $user_roles_table ur
             JOIN $roles_table r ON ur.role_id = r.id
             WHERE ur.user_id = %d
             ORDER BY r.id ASC
             LIMIT 1",
            $user_id
        ));

        return $role_slug;
    }
}
