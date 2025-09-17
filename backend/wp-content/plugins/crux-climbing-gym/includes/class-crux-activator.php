<?php
/**
 * Fired during plugin activation.
 *
 * This class defines all code necessary to run during the plugin's activation.
 *
 * @since      1.0.0
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/includes
 * @author     Your Name <you@example.com>
 */
class Crux_Activator {

    /**
     * Short Description. (use period)
     *
     * Long Description.
     *
     * @since    1.0.0
     */
    public static function activate() {
        // Enable WordPress debug logging
        if (!defined('WP_DEBUG_LOG')) {
            define('WP_DEBUG_LOG', true);
        }
        
        error_log('Crux Plugin: Starting activation');
        
        self::check_requirements();
        self::create_tables();
        self::populate_sample_data();
        
        error_log('Crux Plugin: Activation completed');
    }

    /**
     * Check if WordPress meets our requirements
     */
    private static function check_requirements() {
        global $wp_version;
        
        if (version_compare($wp_version, '5.0', '<')) {
            deactivate_plugins(plugin_basename(__FILE__));
            wp_die('This plugin requires WordPress 5.0 or higher.');
        }
    }

    /**
     * Create database tables for the climbing gym system.
     */
    private static function create_tables() {
        global $wpdb;

        // Enable error reporting
        $wpdb->show_errors();
        
        require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
        
        $charset_collate = $wpdb->get_charset_collate();
        $tables_created = 0;

        // Check if we need to drop and recreate lanes table due to schema change
        $lanes_table = $wpdb->prefix . 'crux_lanes';
        $columns = $wpdb->get_results("SHOW COLUMNS FROM $lanes_table LIKE 'number'");
        if (!empty($columns)) {
            // Old schema detected, drop the table to recreate with new schema
            $wpdb->query("DROP TABLE IF EXISTS $lanes_table");
            error_log("Crux Plugin: Dropped old lanes table with number column");
        }

        // 1. Grades table - MUST be created first due to foreign keys
        $table_name = $wpdb->prefix . 'crux_grades';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            french_name varchar(10) NOT NULL,
            value decimal(3,1) NOT NULL,
            color varchar(7) NOT NULL,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY french_name (french_name)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 2. Hold Colors table
        $table_name = $wpdb->prefix . 'crux_hold_colors';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            name varchar(50) NOT NULL,
            hex_code varchar(7) DEFAULT NULL,
            value int(11) DEFAULT 0,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY name (name)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 3. Lanes table
        $table_name = $wpdb->prefix . 'crux_lanes';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            name varchar(50) DEFAULT NULL,
            is_active tinyint(1) DEFAULT 1,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 4. Routes table
        $table_name = $wpdb->prefix . 'crux_routes';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            name varchar(100) NOT NULL,
            grade_id mediumint(9) NOT NULL,
            route_setter varchar(100) NOT NULL,
            wall_section varchar(50) NOT NULL,
            lane_id mediumint(9) NOT NULL,
            hold_color_id mediumint(9) NOT NULL,
            description text,
            active tinyint(1) DEFAULT 1,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY grade_id (grade_id),
            KEY lane_id (lane_id),
            KEY wall_section (wall_section),
            KEY hold_color_id (hold_color_id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 5. Likes table
        $table_name = $wpdb->prefix . 'crux_likes';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            route_id mediumint(9) NOT NULL,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY user_route (user_id, route_id),
            KEY user_id (user_id),
            KEY route_id (route_id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 6. Comments table
        $table_name = $wpdb->prefix . 'crux_comments';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            route_id mediumint(9) NOT NULL,
            content text NOT NULL,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY user_id (user_id),
            KEY route_id (route_id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 7. Grade Proposals table
        $table_name = $wpdb->prefix . 'crux_grade_proposals';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            route_id mediumint(9) NOT NULL,
            proposed_grade_id mediumint(9) NOT NULL,
            reasoning text,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY user_route (user_id, route_id),
            KEY user_id (user_id),
            KEY route_id (route_id),
            KEY proposed_grade_id (proposed_grade_id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 8. Ticks table (user climbing attempts/sends)
        $table_name = $wpdb->prefix . 'crux_ticks';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            route_id mediumint(9) NOT NULL,
            attempts int(11) DEFAULT 1,
            notes text,
            top_rope_send tinyint(1) DEFAULT 0,
            top_rope_flash tinyint(1) DEFAULT 0,
            lead_send tinyint(1) DEFAULT 0,
            lead_flash tinyint(1) DEFAULT 0,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY user_route (user_id, route_id),
            KEY user_id (user_id),
            KEY route_id (route_id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 9. Projects table (user project routes)
        $table_name = $wpdb->prefix . 'crux_projects';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            route_id mediumint(9) NOT NULL,
            notes text,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY user_route (user_id, route_id),
            KEY user_id (user_id),
            KEY route_id (route_id)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 10. Warnings table
        $table_name = $wpdb->prefix . 'crux_warnings';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            route_id mediumint(9) NOT NULL,
            warning_type varchar(50) NOT NULL,
            description text NOT NULL,
            status varchar(20) DEFAULT 'open',
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY user_id (user_id),
            KEY route_id (route_id),
            KEY status (status)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 11. Roles table
        $table_name = $wpdb->prefix . 'crux_roles';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            name varchar(50) NOT NULL,
            slug varchar(50) NOT NULL,
            description text,
            capabilities text DEFAULT NULL,
            is_active tinyint(1) DEFAULT 1,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY slug (slug),
            KEY name (name)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 12. User Roles table (linking table)
        $table_name = $wpdb->prefix . 'crux_user_roles';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            role_id mediumint(9) NOT NULL,
            assigned_by bigint(20) NOT NULL,
            assigned_at datetime DEFAULT CURRENT_TIMESTAMP,
            is_active tinyint(1) DEFAULT 1,
            PRIMARY KEY (id),
            UNIQUE KEY user_role (user_id, role_id),
            KEY user_id (user_id),
            KEY role_id (role_id),
            KEY assigned_by (assigned_by)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        // 13. User Nicknames table
        $table_name = $wpdb->prefix . 'crux_user_nicknames';
        $sql = "CREATE TABLE $table_name (
            id mediumint(9) NOT NULL AUTO_INCREMENT,
            user_id bigint(20) NOT NULL,
            nickname varchar(100) NOT NULL,
            created_at datetime DEFAULT CURRENT_TIMESTAMP,
            updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY user_id (user_id),
            KEY nickname (nickname)
        ) $charset_collate;";
        
        $result = dbDelta($sql);
        if ($wpdb->get_var("SHOW TABLES LIKE '$table_name'") == $table_name) {
            $tables_created++;
            error_log("Crux Plugin: Successfully created $table_name");
        } else {
            error_log("Crux Plugin: Failed to create $table_name - " . $wpdb->last_error);
        }

        error_log("Crux Plugin: Created $tables_created out of 13 tables");
    }

    /**
     * Populate tables with sample data
     */
    private static function populate_sample_data() {
        global $wpdb;
        
        error_log('Crux Plugin: Starting sample data population');

        // Check if grades table exists and is empty
        $grades_table = $wpdb->prefix . 'crux_grades';
        $grade_count = $wpdb->get_var("SELECT COUNT(*) FROM $grades_table");
        
        if ($grade_count == 0) {
            // Insert French climbing grades
            $grades = array(
                array('1', 1.0, '#90EE90'),  // Light Green
                array('2', 2.0, '#90EE90'),
                array('3a', 3.1, '#FFFF99'), // Light Yellow
                array('3b', 3.2, '#FFFF99'),
                array('3c', 3.3, '#FFFF99'),
                array('4a', 4.1, '#FFD700'), // Gold
                array('4b', 4.2, '#FFD700'),
                array('4c', 4.3, '#FFD700'),
                array('5a', 5.1, '#FFA500'), // Orange
                array('5b', 5.2, '#FFA500'),
                array('5c', 5.3, '#FFA500'),
                array('6a', 6.1, '#FF6347'), // Tomato
                array('6a+', 6.15, '#FF6347'),
                array('6b', 6.2, '#FF6347'),
                array('6b+', 6.25, '#FF6347'),
                array('6c', 6.3, '#FF6347'),
                array('6c+', 6.35, '#FF6347'),
                array('7a', 7.1, '#FF4500'), // Red Orange
                array('7a+', 7.15, '#FF4500'),
                array('7b', 7.2, '#FF4500'),
                array('7b+', 7.25, '#FF4500'),
                array('7c', 7.3, '#FF4500'),
                array('7c+', 7.35, '#FF4500'),
                array('8a', 8.1, '#8B0000'), // Dark Red
                array('8a+', 8.15, '#8B0000'),
                array('8b', 8.2, '#8B0000'),
                array('8b+', 8.25, '#8B0000'),
                array('8c', 8.3, '#8B0000'),
                array('8c+', 8.35, '#8B0000'),
                array('9a', 9.1, '#4B0082'), // Indigo
                array('9a+', 9.15, '#4B0082'),
                array('9b', 9.2, '#4B0082'),
                array('9b+', 9.25, '#4B0082'),
                array('9c', 9.3, '#4B0082')
            );

            $inserted = 0;
            foreach ($grades as $grade) {
                $result = $wpdb->insert(
                    $grades_table,
                    array(
                        'french_name' => $grade[0],
                        'value' => $grade[1],
                        'color' => $grade[2]
                    ),
                    array('%s', '%f', '%s')
                );
                
                if ($result) {
                    $inserted++;
                } else {
                    error_log("Crux Plugin: Failed to insert grade {$grade[0]}: " . $wpdb->last_error);
                }
            }
            
            error_log("Crux Plugin: Inserted $inserted grades");
        } else {
            error_log("Crux Plugin: Grades table already populated ($grade_count records)");
        }

        // Populate hold colors
        $colors_table = $wpdb->prefix . 'crux_hold_colors';
        $color_count = $wpdb->get_var("SELECT COUNT(*) FROM $colors_table");
        
        if ($color_count == 0) {
            $colors = array(
                array('Red', '#FF0000', 1),
                array('Blue', '#0000FF', 2),
                array('Green', '#00FF00', 3),
                array('Yellow', '#FFFF00', 4),
                array('Orange', '#FFA500', 5),
                array('Purple', '#800080', 6),
                array('Pink', '#FFC0CB', 7),
                array('Black', '#000000', 8),
                array('White', '#FFFFFF', 9),
                array('Gray', '#808080', 10)
            );

            $inserted = 0;
            foreach ($colors as $color) {
                $result = $wpdb->insert(
                    $colors_table,
                    array(
                        'name' => $color[0],
                        'hex_code' => $color[1],
                        'value' => $color[2]
                    ),
                    array('%s', '%s', '%d')
                );
                
                if ($result) {
                    $inserted++;
                }
            }
            
            error_log("Crux Plugin: Inserted $inserted hold colors");
        }

        // Populate lanes
        $lanes_table = $wpdb->prefix . 'crux_lanes';
        $lane_count = $wpdb->get_var("SELECT COUNT(*) FROM $lanes_table");
        
        if ($lane_count == 0) {
            for ($i = 1; $i <= 20; $i++) {
                $wpdb->insert(
                    $lanes_table,
                    array(
                        'name' => "Lane $i",
                        'is_active' => 1
                    ),
                    array('%s', '%d')
                );
            }
            
            error_log("Crux Plugin: Inserted 20 lanes");
        }

        // Populate roles
        $roles_table = $wpdb->prefix . 'crux_roles';
        $role_count = $wpdb->get_var("SELECT COUNT(*) FROM $roles_table");
        
        if ($role_count == 0) {
            $roles = array(
                array(
                    'name' => 'Admin',
                    'slug' => 'admin',
                    'description' => 'Administrative access to all gym management features',
                    'capabilities' => json_encode(array(
                        'manage_users',
                        'manage_roles',
                        'create_routes',
                        'edit_routes',
                        'delete_routes',
                        'manage_grades',
                        'manage_hold_colors',
                        'manage_lanes',
                        'view_analytics',
                        'manage_warnings',
                        'moderate_comments',
                        'view_routes',
                        'like_routes',
                        'comment_routes',
                        'track_progress',
                        'propose_grades',
                        'add_projects',
                        'report_warnings'
                    ))
                ),
                array(
                    'name' => 'Route Setter',
                    'slug' => 'route_setter',
                    'description' => 'Can create and manage climbing routes',
                    'capabilities' => json_encode(array(
                        'create_routes',
                        'edit_own_routes',
                        'view_routes',
                        'like_routes',
                        'comment_routes',
                        'track_progress',
                        'propose_grades',
                        'add_projects',
                        'report_warnings'
                    ))
                ),
                array(
                    'name' => 'Member',
                    'slug' => 'member',
                    'description' => 'Regular gym member with standard access',
                    'capabilities' => json_encode(array(
                        'view_routes',
                        'like_routes',
                        'comment_routes',
                        'track_progress',
                        'propose_grades',
                        'add_projects',
                        'report_warnings'
                    ))
                )
            );

            $inserted = 0;
            foreach ($roles as $role) {
                $result = $wpdb->insert(
                    $roles_table,
                    array(
                        'name' => $role['name'],
                        'slug' => $role['slug'],
                        'description' => $role['description'],
                        'capabilities' => $role['capabilities']
                    ),
                    array('%s', '%s', '%s', '%s')
                );
                
                if ($result) {
                    $inserted++;
                } else {
                    error_log("Crux Plugin: Failed to insert role {$role['name']}: " . $wpdb->last_error);
                }
            }
            
            error_log("Crux Plugin: Inserted $inserted roles");
        }
        
        error_log('Crux Plugin: Sample data population completed');
    }
}
