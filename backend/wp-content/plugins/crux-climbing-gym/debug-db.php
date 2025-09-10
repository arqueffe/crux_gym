<?php
// Quick database check - run this from the WordPress admin area or via direct execution
// This assumes WordPress is available

// Include WordPress if this is run directly
if (!defined('WPINC')) {
    require_once('../../../wp-config.php');
}

global $wpdb;

echo "<h2>Database Debug for Crux Plugin</h2>";

// Check routes table
echo "<h3>Routes Table Sample:</h3>";
$routes = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_routes LIMIT 5");
if ($routes) {
    echo "<pre>";
    foreach ($routes as $route) {
        echo "Route ID: {$route->id}, Name: {$route->name}, Lane ID: {$route->lane_id}, Hold Color ID: {$route->hold_color_id}\n";
    }
    echo "</pre>";
} else {
    echo "No routes found.";
}

// Check lanes table
echo "<h3>Lanes Table:</h3>";
$lanes = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_lanes LIMIT 5");
if ($lanes) {
    echo "<pre>";
    foreach ($lanes as $lane) {
        echo "Lane ID: {$lane->id}, Number: {$lane->number}, Name: {$lane->name}, Active: {$lane->is_active}\n";
    }
    echo "</pre>";
} else {
    echo "No lanes found.";
}

// Check hold colors table
echo "<h3>Hold Colors Table:</h3>";
$colors = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}crux_hold_colors LIMIT 5");
if ($colors) {
    echo "<pre>";
    foreach ($colors as $color) {
        echo "Color ID: {$color->id}, Name: {$color->name}, Hex: {$color->hex_code}\n";
    }
    echo "</pre>";
} else {
    echo "No hold colors found.";
}

// Test the exact query from the admin class
echo "<h3>Test Join Query:</h3>";
$test_routes = $wpdb->get_results(
    "SELECT r.*, g.french_name as grade, g.color as grade_color, l.number as lane, 
            hc.name as color_name, hc.hex_code as color
     FROM {$wpdb->prefix}crux_routes r
     LEFT JOIN {$wpdb->prefix}crux_grades g ON r.grade_id = g.id
     LEFT JOIN {$wpdb->prefix}crux_lanes l ON r.lane_id = l.id
     LEFT JOIN {$wpdb->prefix}crux_hold_colors hc ON r.hold_color_id = hc.id
     ORDER BY r.created_at DESC
     LIMIT 3"
);

if ($test_routes) {
    echo "<pre>";
    foreach ($test_routes as $route) {
        echo "Properties available: " . implode(', ', array_keys((array)$route)) . "\n";
        echo "Lane value: " . (isset($route->lane) ? $route->lane : 'NOT SET') . "\n";
        echo "Color value: " . (isset($route->color) ? $route->color : 'NOT SET') . "\n";
        echo "---\n";
    }
    echo "</pre>";
} else {
    echo "No routes found in join query.";
}
?>
