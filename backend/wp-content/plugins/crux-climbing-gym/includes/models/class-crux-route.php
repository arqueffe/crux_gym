<?php

/**
 * Route model class
 */
class Crux_Route {
    
    /**
     * Get all routes with optional filtering
     */
    public static function get_all($filters = array()) {
        global $wpdb;
        
        $routes_table = $wpdb->prefix . 'crux_routes';
        
        $sql = "SELECT r.*
                FROM $routes_table r
                WHERE r.active = 1";
        
        $params = array();
        
        // Apply filters
        if (!empty($filters['wall_section'])) {
            $sql .= " AND r.wall_section = %s";
            $params[] = $filters['wall_section'];
        }
        
        if (!empty($filters['grade_id'])) {
            $sql .= " AND r.grade_id = %d";
            $params[] = intval($filters['grade_id']);
        }
        
        if (!empty($filters['lane_id'])) {
            $sql .= " AND r.lane_id = %d";
            $params[] = intval($filters['lane_id']);
        }
        
        $sql .= " ORDER BY r.created_at DESC";
        
        if (!empty($params)) {
            $sql = $wpdb->prepare($sql, $params);
        }
        
        return $wpdb->get_results($sql);
    }
    
    /**
     * Get route by ID
     */
    public static function get_by_id($id) {
        global $wpdb;
        
        $routes_table = $wpdb->prefix . 'crux_routes';
        
        $sql = $wpdb->prepare("
            SELECT r.*
            FROM $routes_table r
            WHERE r.id = %d
        ", $id);
        
        return $wpdb->get_row($sql);
    }
    
    /**
     * Create new route
     */
    public static function create($data) {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_routes';
        
        $result = $wpdb->insert(
            $table_name,
            array(
                'name' => $data['name'],
                'grade_id' => $data['grade_id'],
                'route_setter' => $data['route_setter'],
                'wall_section' => $data['wall_section'],
                'lane_id' => $data['lane_id'],
                'hold_color_id' => $data['hold_color_id'],
                'description' => $data['description'],
                'active' => 1,
                'created_at' => current_time('mysql')
            ),
            array('%s', '%d', '%s', '%s', '%d', '%d', '%s', '%d', '%s')
        );
        
        if ($result === false) {
            return false;
        }
        
        return $wpdb->insert_id;
    }
    
    /**
     * Update route
     */
    public static function update($id, $data) {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_routes';
        
        $update_data = array();
        $format = array();
        
        if (isset($data['name'])) {
            $update_data['name'] = $data['name'];
            $format[] = '%s';
        }
        
        if (isset($data['grade_id'])) {
            $update_data['grade_id'] = $data['grade_id'];
            $format[] = '%d';
        }
        
        if (isset($data['route_setter'])) {
            $update_data['route_setter'] = $data['route_setter'];
            $format[] = '%s';
        }
        
        if (isset($data['wall_section'])) {
            $update_data['wall_section'] = $data['wall_section'];
            $format[] = '%s';
        }
        
        if (isset($data['lane_id'])) {
            $update_data['lane_id'] = $data['lane_id'];
            $format[] = '%d';
        }
        
        if (isset($data['hold_color_id'])) {
            $update_data['hold_color_id'] = $data['hold_color_id'];
            $format[] = '%d';
        }
        
        if (isset($data['description'])) {
            $update_data['description'] = $data['description'];
            $format[] = '%s';
        }
        
        if (empty($update_data)) {
            return false;
        }
        
        $result = $wpdb->update(
            $table_name,
            $update_data,
            array('id' => $id),
            $format,
            array('%d')
        );
        
        return $result !== false;
    }
    
    /**
     * Get route statistics
     */
    public static function get_stats($route_id) {
        global $wpdb;
        
        $likes_table = $wpdb->prefix . 'crux_likes';
        $comments_table = $wpdb->prefix . 'crux_comments';
        $ticks_table = $wpdb->prefix . 'crux_ticks';
        $warnings_table = $wpdb->prefix . 'crux_warnings';
        $proposals_table = $wpdb->prefix . 'crux_grade_proposals';
        $projects_table = $wpdb->prefix . 'crux_projects';
        
        $stats = array();
        
        // Count likes
        $stats['likes_count'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $likes_table WHERE route_id = %d", $route_id
        ));
        
        // Count comments
        $stats['comments_count'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $comments_table WHERE route_id = %d", $route_id
        ));
        
        // Count ticks
        $stats['ticks_count'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $ticks_table WHERE route_id = %d", $route_id
        ));
        
        // Count warnings
        $stats['warnings_count'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $warnings_table WHERE route_id = %d", $route_id
        ));
        
        // Count grade proposals
        $stats['grade_proposals_count'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $proposals_table WHERE route_id = %d", $route_id
        ));
        
        // Count projects
        $stats['projects_count'] = $wpdb->get_var($wpdb->prepare(
            "SELECT COUNT(*) FROM $projects_table WHERE route_id = %d", $route_id
        ));
        
        return $stats;
    }
}
