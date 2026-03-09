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
            'edit_posts',
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

        // Import Routes submenu
        add_submenu_page(
            'crux-climbing-gym',
            'Import Routes',
            'Import Routes',
            'manage_options',
            'crux-import-routes',
            array($this, 'displayImportRoutesPage')
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

        $edit_route_id = 0;
        if (isset($_GET['route_id'])) {
            $edit_route_id = intval($_GET['route_id']);
        }
        if (isset($_POST['route_id'])) {
            $edit_route_id = intval($_POST['route_id']);
        }

        $editing_route = null;
        if ($edit_route_id > 0) {
            $editing_route = Crux_Route::get_by_id($edit_route_id);
            if (!$editing_route) {
                echo '<div class="notice notice-error is-dismissible"><p>Route not found for editing.</p></div>';
                $edit_route_id = 0;
            }
        }

        // Handle form submission
        if (isset($_POST['submit'])) {
            check_admin_referer('crux_add_route', 'crux_add_route_nonce');
            $is_edit_submit = $edit_route_id > 0 && $editing_route;
            $result = $is_edit_submit
                ? $this->update_route($edit_route_id, $_POST, $_FILES)
                : $this->create_route($_POST, $_FILES);
            
            if ($result['success']) {
                // Redirect to prevent form resubmission
                $redirect_args = array(
                    'page' => 'crux-add-route',
                );

                if ($is_edit_submit) {
                    $redirect_args['route_updated'] = '1';
                    $redirect_args['route_id'] = $edit_route_id;
                } else {
                    $redirect_args['route_created'] = '1';
                }

                $redirect_url = add_query_arg($redirect_args, admin_url('admin.php'));
                // Cannot use wp_redirect here as header are already sent.
                // wp_redirect($redirect_url);
                // Dirty hack instead for redirection
                echo("<script>location.href = '".$redirect_url."'</script>");
                exit;
            } else {
                // Store error in transient for display after redirect
                set_transient('crux_admin_error', $result['message'], 30);
                $redirect_args = array(
                    'page' => 'crux-add-route',
                    'error' => '1'
                );

                if ($is_edit_submit) {
                    $redirect_args['route_id'] = $edit_route_id;
                }

                $redirect_url = add_query_arg($redirect_args, admin_url('admin.php'));
                //wp_redirect($redirect_url);
                echo("<script>location.href = '".$redirect_url."'</script>");
                exit;
            }
        }

        // Show success message after redirect
        if (isset($_GET['route_created']) && $_GET['route_created'] == '1') {
            echo '<div class="notice notice-success is-dismissible"><p>Route created successfully!</p></div>';
        }

        if (isset($_GET['route_updated']) && $_GET['route_updated'] == '1') {
            echo '<div class="notice notice-success is-dismissible"><p>Route updated successfully!</p></div>';
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

        if ($editing_route && !in_array($editing_route->route_setter, $route_setters, true)) {
            $route_setters[] = $editing_route->route_setter;
            sort($route_setters);
        }

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-add-route.php';
    }

    /**
     * Display import routes page
     */
    public function displayImportRoutesPage() {
        global $wpdb;

        $grades = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_grades ORDER BY value ASC");
        $hold_colors = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_hold_colors ORDER BY name ASC");
        $lanes = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_lanes WHERE is_active = 1 ORDER BY id ASC");
        $wall_sections = Crux_Wall_Section::get_all(true);

        $parsed_routes = array();
        $import_errors = array();
        $import_notices = array();
        $imported_count = 0;
        $available_images = array();

        if (isset($_POST['available_images']) && is_array($_POST['available_images'])) {
            $available_images = array_values(array_unique(array_filter(array_map('esc_url_raw', wp_unslash($_POST['available_images'])))));
        }

        if (isset($_POST['crux_import_parse'])) {
            check_admin_referer('crux_import_routes_parse', 'crux_import_routes_nonce');

            if (empty($_FILES['routes_json_file']['tmp_name']) || !is_uploaded_file($_FILES['routes_json_file']['tmp_name'])) {
                $import_errors[] = 'Please select a valid JSON file to import.';
            } else {
                $parse_result = $this->parseImportRoutesJson($_FILES['routes_json_file']['tmp_name']);
                if ($parse_result['success']) {
                    $parsed_routes = $parse_result['routes'];
                    $available_images = array_values(array_unique(array_merge(
                        $available_images,
                        $this->collectImportImagesFromRoutes($parsed_routes)
                    )));
                } else {
                    $import_errors[] = $parse_result['message'];
                }
            }
        }

        if (isset($_POST['crux_import_upload_images']) || isset($_POST['crux_import_submit'])) {
            check_admin_referer('crux_import_routes_submit', 'crux_import_routes_submit_nonce');

            $raw_rows = isset($_POST['route_rows']) && is_array($_POST['route_rows']) ? wp_unslash($_POST['route_rows']) : array();

            if (empty($raw_rows)) {
                $import_errors[] = 'No routes were provided for import.';
            } else {
                $parsed_routes = array();

                foreach ($raw_rows as $index => $row) {
                    $is_enabled = isset($row['enabled']) && intval($row['enabled']) === 1;
                    $normalized = $this->normalizeImportRoute($row, $index + 1);
                    $normalized['enabled'] = $is_enabled ? 1 : 0;
                    $parsed_routes[] = $normalized;
                }

                $available_images = array_values(array_unique(array_merge(
                    $available_images,
                    $this->collectImportImagesFromRoutes($parsed_routes)
                )));

                if (isset($_POST['crux_import_upload_images'])) {
                    $upload_result = $this->handleImportImageUploads(isset($_FILES['route_images']) ? $_FILES['route_images'] : array());

                    $available_images = array_values(array_unique(array_merge(
                        $available_images,
                        $upload_result['images']
                    )));

                    if (!empty($upload_result['errors'])) {
                        $import_errors = array_merge($import_errors, $upload_result['errors']);
                    } elseif (!empty($upload_result['images'])) {
                        $import_notices[] = count($upload_result['images']) . ' image(s) uploaded successfully.';
                    }
                }

                if (isset($_POST['crux_import_submit'])) {
                    $selected_routes = array();
                    foreach ($parsed_routes as $route) {
                        if (intval($route['enabled']) === 1) {
                            $selected_routes[] = $route;
                        }
                    }

                    if (empty($selected_routes)) {
                        $import_errors[] = 'No enabled routes to import.';
                    } else {
                        $validation_errors = array();

                        foreach ($selected_routes as $route_data) {
                            $row_label = !empty($route_data['_row_label']) ? $route_data['_row_label'] : 'Unknown row';

                            if (empty($route_data['name']) || empty($route_data['grade_id']) || empty($route_data['route_setter']) || empty($route_data['wall_section']) || empty($route_data['lane_id'])) {
                                $validation_errors[] = $row_label . ': missing required fields (name, grade, setter, wall section, lane).';
                                continue;
                            }
                            $grade_exists = $wpdb->get_var($wpdb->prepare(
                                "SELECT id FROM {$wpdb->prefix}crux_grades WHERE id = %d",
                                $route_data['grade_id']
                            ));

                            $lane_exists = $wpdb->get_var($wpdb->prepare(
                                "SELECT id FROM {$wpdb->prefix}crux_lanes WHERE id = %d",
                                $route_data['lane_id']
                            ));

                            if (!$grade_exists) {
                                $validation_errors[] = $row_label . ': invalid grade ID (' . intval($route_data['grade_id']) . ').';
                                continue;
                            }

                            if (!$lane_exists) {
                                $validation_errors[] = $row_label . ': invalid lane ID (' . intval($route_data['lane_id']) . ').';
                                continue;
                            }
                        }

                        if (!empty($validation_errors)) {
                            $import_errors = array_merge($import_errors, $validation_errors);
                        } else {
                            $wpdb->query('START TRANSACTION');

                            $inserted_route_ids = array();
                            $failed_row_label = '';
                            $failed_db_error = '';

                            foreach ($selected_routes as $route_data) {
                                $row_label = !empty($route_data['_row_label']) ? $route_data['_row_label'] : 'Unknown row';

                                $insert_result = $wpdb->insert(
                                    $wpdb->prefix . 'crux_routes',
                                    array(
                                        'name' => sanitize_text_field($route_data['name']),
                                        'grade_id' => intval($route_data['grade_id']),
                                        'route_setter' => sanitize_text_field($route_data['route_setter']),
                                        'image' => esc_url_raw($route_data['image']),
                                        'wall_section' => sanitize_text_field($route_data['wall_section']),
                                        'lane_id' => intval($route_data['lane_id']),
                                        'hold_color_id' => !empty($route_data['hold_color_id']) ? intval($route_data['hold_color_id']) : null,
                                        'description' => !empty($route_data['description']) ? sanitize_textarea_field($route_data['description']) : null,
                                        'active' => intval($route_data['active']) === 1 ? 1 : 0,
                                        'created_at' => !empty($route_data['created_at']) ? sanitize_text_field($route_data['created_at']) : current_time('mysql')
                                    )
                                );

                                if ($insert_result === false) {
                                    $failed_row_label = $row_label;
                                    $failed_db_error = $wpdb->last_error;
                                    break;
                                }

                                $inserted_route_ids[] = intval($wpdb->insert_id);
                            }

                            if (!empty($failed_row_label)) {
                                $wpdb->query('ROLLBACK');

                                if (!empty($inserted_route_ids)) {
                                    foreach ($inserted_route_ids as $inserted_id) {
                                        $wpdb->delete($wpdb->prefix . 'crux_routes', array('id' => $inserted_id), array('%d'));
                                    }
                                }

                                $imported_count = 0;
                                $import_errors[] = $failed_row_label . ': database error - ' . $failed_db_error . '. Import aborted: no routes were imported.';
                            } else {
                                $wpdb->query('COMMIT');
                                $imported_count = count($selected_routes);
                                $parsed_routes = array();
                                $available_images = array();
                            }

                        }
                    }
                }
            }
        }

        include_once CRUX_CLIMBING_GYM_PLUGIN_DIR . 'admin/partials/crux-admin-import-routes.php';
    }

    /**
     * Collect non-empty image URLs from parsed routes.
     */
    private function collectImportImagesFromRoutes($routes) {
        $images = array();

        foreach ($routes as $route) {
            if (!is_array($route) || empty($route['image'])) {
                continue;
            }

            $images[] = esc_url_raw((string) $route['image']);
        }

        return array_values(array_unique(array_filter($images)));
    }

    /**
     * Handle image uploads for route import review.
     */
    private function handleImportImageUploads($files_input) {
        $result = array(
            'images' => array(),
            'errors' => array()
        );

        if (empty($files_input) || empty($files_input['name'])) {
            return $result;
        }

        require_once ABSPATH . 'wp-admin/includes/file.php';

        $names = is_array($files_input['name']) ? $files_input['name'] : array($files_input['name']);
        $types = is_array($files_input['type']) ? $files_input['type'] : array($files_input['type']);
        $tmp_names = is_array($files_input['tmp_name']) ? $files_input['tmp_name'] : array($files_input['tmp_name']);
        $errors = is_array($files_input['error']) ? $files_input['error'] : array($files_input['error']);
        $sizes = is_array($files_input['size']) ? $files_input['size'] : array($files_input['size']);

        foreach ($names as $index => $name) {
            if (empty($name)) {
                continue;
            }

            if (!isset($errors[$index]) || intval($errors[$index]) !== UPLOAD_ERR_OK) {
                $result['errors'][] = 'Failed to upload image "' . sanitize_text_field($name) . '".';
                continue;
            }

            $single_file = array(
                'name' => $name,
                'type' => isset($types[$index]) ? $types[$index] : '',
                'tmp_name' => isset($tmp_names[$index]) ? $tmp_names[$index] : '',
                'error' => $errors[$index],
                'size' => isset($sizes[$index]) ? $sizes[$index] : 0
            );

            $upload = wp_handle_upload($single_file, array('test_form' => false));

            if (!empty($upload['error'])) {
                $result['errors'][] = 'Failed to upload image "' . sanitize_text_field($name) . '": ' . $upload['error'];
                continue;
            }

            if (!empty($upload['url'])) {
                $result['images'][] = esc_url_raw($upload['url']);
            }
        }

        $result['images'] = array_values(array_unique(array_filter($result['images'])));

        return $result;
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
    private function create_route($data, $file) {
        global $wpdb;

        // Check if we have an edited image (base64 data)
        if (!empty($data['route_image_edited'])) {
            // Handle edited image from canvas
            $image_data = $data['route_image_edited'];
            
            // Remove data URL prefix (data:image/png;base64,)
            if (strpos($image_data, 'data:image') === 0) {
                $image_data = substr($image_data, strpos($image_data, ',') + 1);
            }
            
            $decoded_image = base64_decode($image_data);
            
            if ($decoded_image === false) {
                return array('success' => false, 'message' => 'Failed to decode edited image.');
            }
            
            // Verify it's a valid image by checking the header
            $image_info = @getimagesizefromstring($decoded_image);
            if ($image_info === false) {
                return array('success' => false, 'message' => 'Decoded data is not a valid image.');
            }
            
            // Use wp_upload_bits which is designed for programmatic uploads
            $filename = 'route-edited-' . time() . '.png';
            $upload = wp_upload_bits($filename, null, $decoded_image);
            
            if ($upload['error'] !== false) {
                return array('success' => false, 'message' => 'Failed to upload edited image: ' . $upload['error']);
            }
        } elseif ($file['route_image']['name'] != '') {
            // Handle regular file upload
            $isAnImage = getimagesize($file['route_image']['tmp_name']) ? true : false;
            if (!$isAnImage) {
                return array('success' => false, 'message' => 'Uploaded file is not a valid image.');
            }
            // Could limit image size & resize using wp_get_image_editor
            $upload_overrides = array( 'test_form' => false );
            $upload = wp_handle_upload($file['route_image'], $upload_overrides);

            if ($upload == null || isset($upload['error'])) {
                return array('success' => false, 'message' => 'Failed to upload route image: '. $upload['error']);
            }
        } else {
            $upload = null;
        }
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
                'image' => $upload['url'],
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
     * Update an existing route
     */
    private function update_route($route_id, $data, $file) {
        global $wpdb;

        $existing_route = Crux_Route::get_by_id($route_id);
        if (!$existing_route) {
            return array('success' => false, 'message' => 'Route not found');
        }

        $image_url = $existing_route->image;

        if (!empty($data['route_image_edited'])) {
            $image_data = $data['route_image_edited'];

            if (strpos($image_data, 'data:image') === 0) {
                $image_data = substr($image_data, strpos($image_data, ',') + 1);
            }

            $decoded_image = base64_decode($image_data);
            if ($decoded_image === false) {
                return array('success' => false, 'message' => 'Failed to decode edited image.');
            }

            $image_info = @getimagesizefromstring($decoded_image);
            if ($image_info === false) {
                return array('success' => false, 'message' => 'Decoded data is not a valid image.');
            }

            $filename = 'route-edited-' . time() . '.png';
            $upload = wp_upload_bits($filename, null, $decoded_image);

            if ($upload['error'] !== false) {
                return array('success' => false, 'message' => 'Failed to upload edited image: ' . $upload['error']);
            }

            $image_url = $upload['url'];
        } elseif (isset($file['route_image']['name']) && $file['route_image']['name'] !== '') {
            $is_an_image = getimagesize($file['route_image']['tmp_name']) ? true : false;
            if (!$is_an_image) {
                return array('success' => false, 'message' => 'Uploaded file is not a valid image.');
            }

            $upload_overrides = array('test_form' => false);
            $upload = wp_handle_upload($file['route_image'], $upload_overrides);

            if ($upload == null || isset($upload['error'])) {
                return array('success' => false, 'message' => 'Failed to upload route image: ' . $upload['error']);
            }

            $image_url = $upload['url'];
        }

        $is_unnamed = isset($data['unnamed_route']) && $data['unnamed_route'] == '1';
        $route_name = $is_unnamed ? 'Unnamed' : $data['route_name'];

        if (!$is_unnamed && empty($data['route_name'])) {
            return array('success' => false, 'message' => 'Route name is required unless "Leave unnamed" is checked');
        }

        if (empty($data['grade_id']) || empty($data['route_setter']) ||
            empty($data['wall_section']) || empty($data['lane_id'])) {
            return array('success' => false, 'message' => 'All required fields must be filled');
        }

        $grade_exists = $wpdb->get_var($wpdb->prepare(
            "SELECT id FROM {$wpdb->prefix}crux_grades WHERE id = %d",
            $data['grade_id']
        ));

        if (!$grade_exists) {
            return array('success' => false, 'message' => 'Invalid grade selected');
        }

        $lane_exists = $wpdb->get_var($wpdb->prepare(
            "SELECT id FROM {$wpdb->prefix}crux_lanes WHERE id = %d",
            $data['lane_id']
        ));

        if (!$lane_exists) {
            return array('success' => false, 'message' => 'Invalid lane selected');
        }

        $update_data = array(
            'name' => sanitize_text_field($route_name),
            'grade_id' => (int) $data['grade_id'],
            'route_setter' => sanitize_text_field($data['route_setter']),
            'image' => $image_url,
            'wall_section' => sanitize_text_field($data['wall_section']),
            'lane_id' => (int) $data['lane_id'],
            'hold_color_id' => !empty($data['hold_color_id']) ? (int) $data['hold_color_id'] : null,
            'description' => !empty($data['description']) ? sanitize_textarea_field($data['description']) : null,
        );

        $result = $wpdb->update(
            $wpdb->prefix . 'crux_routes',
            $update_data,
            array('id' => $route_id)
        );

        if ($result === false) {
            return array('success' => false, 'message' => 'Database error: ' . $wpdb->last_error);
        }

        return array('success' => true, 'route_id' => $route_id);
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
     * Parse routes import JSON file and normalize routes data.
     */
    private function parseImportRoutesJson($file_path) {
        $content = file_get_contents($file_path);
        if ($content === false) {
            return array(
                'success' => false,
                'message' => 'Unable to read the uploaded file.'
            );
        }

        $decoded = json_decode($content, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            return array(
                'success' => false,
                'message' => 'Invalid JSON file: ' . json_last_error_msg()
            );
        }

        $routes_data = array();

        if (is_array($decoded) && isset($decoded[0]['type']) && $decoded[0]['type'] === 'header') {
            foreach ($decoded as $entry) {
                if (isset($entry['type'], $entry['name'], $entry['data']) && $entry['type'] === 'table' && $entry['name'] === 'wp_crux_routes' && is_array($entry['data'])) {
                    $routes_data = $entry['data'];
                    break;
                }
            }
        } elseif (is_array($decoded) && isset($decoded['routes']) && is_array($decoded['routes'])) {
            $routes_data = $decoded['routes'];
        } elseif (is_array($decoded)) {
            $routes_data = $decoded;
        }

        if (empty($routes_data)) {
            return array(
                'success' => false,
                'message' => 'No routes found in JSON. Expected an array of routes, a "routes" key, or a phpMyAdmin table export for wp_crux_routes.'
            );
        }

        $normalized_routes = array();
        foreach ($routes_data as $index => $route) {
            if (!is_array($route)) {
                continue;
            }
            $normalized_routes[] = $this->normalizeImportRoute($route, $index + 1);
        }

        if (empty($normalized_routes)) {
            return array(
                'success' => false,
                'message' => 'No valid route objects found in JSON.'
            );
        }

        return array(
            'success' => true,
            'routes' => $normalized_routes
        );
    }

    /**
     * Normalize a single route row for review/import.
     */
    private function normalizeImportRoute($route, $fallback_index) {
        return array(
            'enabled' => !isset($route['enabled']) ? 1 : intval($route['enabled']),
            'name' => isset($route['name']) && $route['name'] !== '' ? (string) $route['name'] : 'Unnamed',
            'grade_id' => isset($route['grade_id']) ? intval($route['grade_id']) : 0,
            'route_setter' => isset($route['route_setter']) ? (string) $route['route_setter'] : '',
            'image' => isset($route['image']) ? (string) $route['image'] : '',
            'wall_section' => isset($route['wall_section']) ? (string) $route['wall_section'] : '',
            'lane_id' => isset($route['lane_id']) ? intval($route['lane_id']) : 0,
            'hold_color_id' => isset($route['hold_color_id']) && $route['hold_color_id'] !== '' ? intval($route['hold_color_id']) : '',
            'description' => isset($route['description']) ? (string) $route['description'] : '',
            'active' => isset($route['active']) ? intval($route['active']) : 1,
            'created_at' => isset($route['created_at']) && !empty($route['created_at']) ? (string) $route['created_at'] : current_time('mysql'),
            '_row_label' => isset($route['id']) ? 'ID ' . intval($route['id']) : 'Row ' . intval($fallback_index)
        );
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
        $new_name = sanitize_text_field(wp_unslash($_POST['new_name']));
        
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
            // Convert object to array and ensure proper encoding
            $route_array = array(
                'id' => $route->id,
                'name' => wp_specialchars_decode($route->name, ENT_QUOTES),
                'grade_id' => $route->grade_id,
                'route_setter' => wp_specialchars_decode($route->route_setter, ENT_QUOTES),
                'wall_section' => wp_specialchars_decode($route->wall_section, ENT_QUOTES),
                'lane_id' => $route->lane_id,
                'hold_color_id' => $route->hold_color_id,
                'image' => $route->image,
                'description' => wp_specialchars_decode($route->description, ENT_QUOTES),
                'created_at' => $route->created_at
            );
            
            wp_send_json_success(array(
                'route' => $route_array
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
            'name' => sanitize_text_field(wp_unslash($_POST['name'])),
            'grade_id' => intval($_POST['grade_id']),
            'route_setter' => sanitize_text_field(wp_unslash($_POST['route_setter'])),
            'wall_section' => sanitize_text_field(wp_unslash($_POST['wall_section'])),
            'lane_id' => intval($_POST['lane_id']),
            'hold_color_id' => !empty($_POST['hold_color_id']) ? intval($_POST['hold_color_id']) : null,
            'description' => sanitize_textarea_field(wp_unslash($_POST['description']))
        );
        
        // Handle image upload or removal
        $remove_image = isset($_POST['remove_image']) && $_POST['remove_image'] === '1';
        $current_image = isset($_POST['current_image']) ? sanitize_text_field($_POST['current_image']) : '';
        
        if ($remove_image) {
            // Remove image
            $data['image'] = null;
        } elseif (!empty($_FILES['route_image']['name'])) {
            // New image uploaded
            require_once(ABSPATH . 'wp-admin/includes/file.php');
            
            $uploadedfile = $_FILES['route_image'];
            $upload_overrides = array('test_form' => false);
            $movefile = wp_handle_upload($uploadedfile, $upload_overrides);
            
            if ($movefile && !isset($movefile['error'])) {
                $data['image'] = $movefile['url'];
            } else {
                wp_send_json_error(array('message' => 'Failed to upload image: ' . $movefile['error']));
                return;
            }
        } elseif (!empty($current_image)) {
            // Keep current image (don't update image field)
            // No need to include it in $data
        }
        
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
