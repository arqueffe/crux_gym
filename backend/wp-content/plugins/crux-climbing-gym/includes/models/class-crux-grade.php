<?php

/**
 * Grade model class
 */
class Crux_Grade {
    
    /**
     * Get all grades ordered by difficulty
     */
    public static function get_all() {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_grades';
        
        $sql = "SELECT *, french_name as grade, value as difficulty_order FROM $table_name ORDER BY value ASC";
        
        return $wpdb->get_results($sql, ARRAY_A);
    }
    
    /**
     * Get grade by ID
     */
    public static function get_by_id($id) {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_grades';
        
        $sql = $wpdb->prepare("SELECT * FROM $table_name WHERE id = %d", $id);
        
        return $wpdb->get_row($sql, ARRAY_A);
    }
    
    /**
     * Get grade by grade string
     */
    public static function get_by_grade($grade) {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_grades';
        
        $sql = $wpdb->prepare("SELECT * FROM $table_name WHERE french_name = %s", $grade);
        
        return $wpdb->get_row($sql);
    }
    
    /**
     * Get grade colors mapping
     */
    public static function get_colors() {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_grades';
        
        $sql = "SELECT french_name, color FROM $table_name ORDER BY value ASC";
        
        $results = $wpdb->get_results($sql);
        
        $colors = array();
        foreach ($results as $result) {
            $colors[$result->french_name] = $result->color;
        }
        
        return $colors;
    }
    
    /**
     * Get all unique grades as simple array
     */
    public static function get_grades_list() {
        global $wpdb;
        
        $table_name = $wpdb->prefix . 'crux_grades';
        
        $sql = "SELECT french_name FROM $table_name ORDER BY value ASC";
        
        return $wpdb->get_col($sql);
    }
}
