<?php

/**
 * Wall Section model class
 */
class Crux_Wall_Section {
    
    /**
     * Get all wall sections
     */
    public static function get_all($active_only = false) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_wall_sections';

        $sql = "SELECT * FROM $table_name";
        
        if ($active_only) {
            $sql .= " WHERE is_active = 1";
        }
        
        $sql .= " ORDER BY sort_order ASC, name ASC";
        
        return $wpdb->get_results($sql);
    }
    
    /**
     * Get wall section by ID
     */
    public static function get_by_id($id) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_wall_sections';

        $sql = $wpdb->prepare("SELECT * FROM $table_name WHERE id = %d", $id);
        
        return $wpdb->get_row($sql, ARRAY_A);
    }
    
    /**
     * Get wall section by name
     */
    public static function get_by_name($name) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_wall_sections';

        $sql = $wpdb->prepare("SELECT * FROM $table_name WHERE name = %s", $name);
        
        return $wpdb->get_row($sql, ARRAY_A);
    }
    
    /**
     * Create new wall section
     */
    public static function create($data) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_wall_sections';
        
        $insert_data = array(
            'name' => sanitize_text_field($data['name']),
            'description' => isset($data['description']) ? sanitize_textarea_field($data['description']) : '',
            'sort_order' => isset($data['sort_order']) ? intval($data['sort_order']) : 0,
            'is_active' => isset($data['is_active']) ? intval($data['is_active']) : 1,
        );
        
        $result = $wpdb->insert($table_name, $insert_data);
        
        if ($result === false) {
            return false;
        }
        
        return $wpdb->insert_id;
    }
    
    /**
     * Update wall section
     */
    public static function update($id, $data) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_wall_sections';
        
        $update_data = array();
        
        if (isset($data['name'])) {
            $update_data['name'] = sanitize_text_field($data['name']);
        }
        
        if (isset($data['description'])) {
            $update_data['description'] = sanitize_textarea_field($data['description']);
        }
        
        if (isset($data['sort_order'])) {
            $update_data['sort_order'] = intval($data['sort_order']);
        }
        
        if (isset($data['is_active'])) {
            $update_data['is_active'] = intval($data['is_active']);
        }
        
        if (empty($update_data)) {
            return false;
        }
        
        $result = $wpdb->update(
            $table_name,
            $update_data,
            array('id' => $id)
        );
        
        return $result !== false;
    }
    
    /**
     * Delete wall section
     */
    public static function delete($id) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_wall_sections';
        
        $result = $wpdb->delete($table_name, array('id' => $id));
        
        return $result !== false;
    }
    
    /**
     * Get wall sections as simple name list
     */
    public static function get_names_list($active_only = true) {
        $sections = self::get_all($active_only);
        
        return array_map(function($section) {
            return $section->name;
        }, $sections);
    }
}
