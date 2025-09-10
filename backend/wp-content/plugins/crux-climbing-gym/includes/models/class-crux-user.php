<?php

/**
 * User model class (extends WordPress user functionality)
 */
class Crux_User {
    
    /**
     * Get all users from WordPress users table
     */
    public static function get_all() {
        global $wpdb;
        
        $sql = "
            SELECT u.ID as id, u.user_login as username, u.user_email as email, 
                   u.display_name as nickname, u.user_registered as created_at,
                   um1.meta_value as first_name, um2.meta_value as last_name,
                   um3.meta_value as last_login,
                   CASE WHEN um4.meta_value IS NOT NULL THEN 1 ELSE 0 END as admin,
                   1 as active
            FROM {$wpdb->users} u
            LEFT JOIN {$wpdb->usermeta} um1 ON u.ID = um1.user_id AND um1.meta_key = 'first_name'
            LEFT JOIN {$wpdb->usermeta} um2 ON u.ID = um2.user_id AND um2.meta_key = 'last_name'
            LEFT JOIN {$wpdb->usermeta} um3 ON u.ID = um3.user_id AND um3.meta_key = 'last_login'
            LEFT JOIN {$wpdb->usermeta} um4 ON u.ID = um4.user_id AND um4.meta_key = 'wp_capabilities' AND um4.meta_value LIKE '%administrator%'
            ORDER BY u.user_registered DESC
        ";
        
        $users = $wpdb->get_results($sql);
        
        // Convert to objects for consistency
        foreach ($users as $user) {
            $user->first_name = $user->first_name ?: '';
            $user->last_name = $user->last_name ?: '';
            $user->last_login = $user->last_login ?: null;
        }
        
        return $users;
    }
    
    /**
     * Get user by ID
     */
    public static function get_by_id($user_id) {
        $user = get_user_by('id', $user_id);
        
        if (!$user) {
            return false;
        }
        
        return array(
            'id' => $user->ID,
            'username' => $user->user_login,
            'nickname' => $user->display_name,
            'email' => $user->user_email,
            'created_at' => $user->user_registered,
            'is_active' => true
        );
    }
    
    /**
     * Get user statistics
     */
    public static function get_stats($user_id) {
        global $wpdb;
        
        $ticks_table = $wpdb->prefix . 'crux_ticks';
        $likes_table = $wpdb->prefix . 'crux_likes';
        $comments_table = $wpdb->prefix . 'crux_comments';
        $projects_table = $wpdb->prefix . 'crux_projects';
        $routes_table = $wpdb->prefix . 'crux_routes';
        $grades_table = $wpdb->prefix . 'crux_grades';
        
        $stats = array();
        
        // Basic counts
        $stats['total_ticks'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $ticks_table WHERE user_id = %d", $user_id
        )) ?: 0;
        
        $stats['total_likes'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $likes_table WHERE user_id = %d", $user_id
        )) ?: 0;
        
        $stats['total_comments'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $comments_table WHERE user_id = %d", $user_id
        )) ?: 0;
        
        $stats['total_projects'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $projects_table WHERE user_id = %d", $user_id
        )) ?: 0;
        
        // Send statistics
        $send_stats = $wpdb->get_row($wpdb->prepare("
            SELECT 
                SUM(CASE WHEN top_rope_send = 1 OR lead_send = 1 THEN 1 ELSE 0 END) as total_sends,
                SUM(CASE WHEN top_rope_send = 1 THEN 1 ELSE 0 END) as top_rope_sends,
                SUM(CASE WHEN lead_send = 1 THEN 1 ELSE 0 END) as lead_sends,
                SUM(CASE WHEN top_rope_flash = 1 OR lead_flash = 1 THEN 1 ELSE 0 END) as total_flashes,
                SUM(attempts) as total_attempts
            FROM $ticks_table 
            WHERE user_id = %d
        ", $user_id), ARRAY_A);
        
        $stats = array_merge($stats, $send_stats ?: array());
        
        // Ensure numeric values
        $stats['total_sends'] = intval($stats['total_sends'] ?? 0);
        $stats['total_attempts'] = intval($stats['total_attempts'] ?? 0);
        
        // Calculate average attempts
        $stats['average_attempts'] = $stats['total_ticks'] > 0 ? 
            round($stats['total_attempts'] / $stats['total_ticks'], 2) : 0;
        
        // Get favorite grade (most climbed grade)
        $favorite_grade = $wpdb->get_row($wpdb->prepare("
            SELECT g.french_name as grade, COUNT(*) as count
            FROM $ticks_table t
            JOIN $routes_table r ON t.route_id = r.id
            JOIN $grades_table g ON r.grade_id = g.id
            WHERE t.user_id = %d
            GROUP BY r.grade_id
            ORDER BY count DESC
            LIMIT 1
        ", $user_id));
        
        if ($favorite_grade) {
            $stats['favorite_grade'] = $favorite_grade->grade;
            // Get color for the grade
            $colors = Crux_Grade::get_colors();
            $stats['favorite_grade_color'] = isset($colors[$favorite_grade->grade]) ? $colors[$favorite_grade->grade] : '#cccccc';
        } else {
            $stats['favorite_grade'] = null;
            $stats['favorite_grade_color'] = null;
        }
        
        // Get average grade
        $avg_grade = $wpdb->get_var($wpdb->prepare("
            SELECT AVG(g.value)
            FROM $ticks_table t
            JOIN $routes_table r ON t.route_id = r.id
            JOIN $grades_table g ON r.grade_id = g.id
            WHERE t.user_id = %d
        ", $user_id));
        
        if ($avg_grade) {
            // Find closest grade to average
            $closest_grade = $wpdb->get_var($wpdb->prepare("
                SELECT french_name 
                FROM $grades_table 
                ORDER BY ABS(value - %f) 
                LIMIT 1
            ", $avg_grade));
            $stats['average_grade'] = $closest_grade;
        } else {
            $stats['average_grade'] = null;
        }
        
        return $stats;
    }
    
    /**
     * Get user's ticks with route details
     */
    public static function get_ticks($user_id) {
        global $wpdb;
        
        $ticks_table = $wpdb->prefix . 'crux_ticks';
        $routes_table = $wpdb->prefix . 'crux_routes';
        $grades_table = $wpdb->prefix . 'crux_grades';
        
        $sql = $wpdb->prepare("
            SELECT t.*, r.name as route_name, g.french_name as route_grade, r.wall_section
            FROM $ticks_table t
            LEFT JOIN $routes_table r ON t.route_id = r.id
            LEFT JOIN $grades_table g ON r.grade_id = g.id
            WHERE t.user_id = %d
            ORDER BY t.created_at DESC
        ", $user_id);
        
        return $wpdb->get_results($sql, ARRAY_A);
    }
    
    /**
     * Get user's likes with route details
     */
    public static function get_likes($user_id) {
        global $wpdb;
        
        $likes_table = $wpdb->prefix . 'crux_likes';
        $routes_table = $wpdb->prefix . 'crux_routes';
        $grades_table = $wpdb->prefix . 'crux_grades';
        
        $sql = $wpdb->prepare("
            SELECT l.*, r.name as route_name, g.french_name as route_grade, r.wall_section
            FROM $likes_table l
            LEFT JOIN $routes_table r ON l.route_id = r.id
            LEFT JOIN $grades_table g ON r.grade_id = g.id
            WHERE l.user_id = %d
            ORDER BY l.created_at DESC
        ", $user_id);
        
        return $wpdb->get_results($sql, ARRAY_A);
    }
}
