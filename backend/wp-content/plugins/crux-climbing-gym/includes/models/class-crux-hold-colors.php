<?php

/**
 * Hold Colors model class
 */
class Crux_Hold_Colors {
    
    /**
     * Get all hold colors
     */
    public static function get_all() {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_hold_colors';

        
        $sql = "SELECT * FROM $table_name ORDER BY value ASC";
        
        return $wpdb->get_results($sql);
    }
    
    /**
     * Get hold color by ID
     */
    public static function get_by_id($id) {
        global $wpdb;

        $table_name = $wpdb->prefix . 'crux_hold_colors';

        $sql = $wpdb->prepare("SELECT * FROM $table_name WHERE id = %d", $id);
        
        return $wpdb->get_row($sql, ARRAY_A);
    }
}
