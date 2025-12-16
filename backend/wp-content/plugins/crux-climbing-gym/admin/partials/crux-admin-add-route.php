<?php
/**
 * Admin Add Route Form Template
 *
 * @since      1.0.0
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/admin/partials
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}
?>

<div class="wrap">
    <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
    
    <div class="crux-admin-content">
        <div class="crux-form-container">
            <form method="post" action="" class="crux-add-route-form" enctype="multipart/form-data">
                <?php wp_nonce_field('crux_add_route', 'crux_add_route_nonce'); ?>
                
                <table class="form-table" role="presentation">
                    <tbody>
                        <tr>
                            <th scope="row">
                                <label for="route_name">Route Name *</label>
                            </th>
                            <td>
                                <input name="route_name" type="text" id="route_name" 
                                       value="<?php echo isset($_POST['route_name']) ? esc_attr($_POST['route_name']) : ''; ?>" 
                                       class="regular-text" required />
                                <p class="description">Enter a creative name for the climbing route</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="grade_id">Grade *</label>
                            </th>
                            <td>
                                <select name="grade_id" id="grade_id" required>
                                    <option value="">Select Grade</option>
                                    <?php if (empty($grades)): ?>
                                        <option value="" disabled>No grades found - check database</option>
                                    <?php else: ?>
                                        <?php foreach ($grades as $grade): ?>
                                            <option value="<?php echo esc_attr($grade->id); ?>" 
                                                    style="color: <?php echo esc_attr($grade->color); ?>"
                                                    <?php selected(isset($_POST['grade_id']) ? $_POST['grade_id'] : '', $grade->id); ?>>
                                                <?php echo esc_html($grade->french_name); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    <?php endif; ?>
                                </select>
                                <p class="description">Select the difficulty grade (French system)</p>
                                <?php if (current_user_can('manage_options')): ?>
                                    <p class="description"><small>Debug: <?php echo count($grades); ?> grades loaded</small></p>
                                <?php endif; ?>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="route_image">Route Image</label>
                            </th>
                            <td>
                                <input name="route_image" type="file" id="route_image" accept="image/*"
                                       value="<?php echo isset($_POST['route_image']) ? esc_attr($_POST['route_image']) : ''; ?>"
                                       />
                                <p class="description">Picture of this route</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="route_setter">Route Setter *</label>
                            </th>
                            <td>
                                <input name="route_setter" type="text" id="route_setter" 
                                       value="<?php echo isset($_POST['route_setter']) ? esc_attr($_POST['route_setter']) : ''; ?>" 
                                       class="regular-text" required />
                                <p class="description">Name of the person who set this route</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="wall_section">Wall Section *</label>
                            </th>
                            <td>
                                <input name="wall_section" type="text" id="wall_section" 
                                       value="<?php echo isset($_POST['wall_section']) ? esc_attr($_POST['wall_section']) : ''; ?>" 
                                       class="regular-text" list="wall_sections" required />
                                <datalist id="wall_sections">
                                    <?php foreach ($wall_sections as $section): ?>
                                        <option value="<?php echo esc_attr($section); ?>">
                                    <?php endforeach; ?>
                                    <option value="Overhang Wall">
                                    <option value="Slab Wall">
                                    <option value="Vertical Wall">
                                    <option value="Steep Wall">
                                    <option value="Roof Section">
                                </datalist>
                                <p class="description">Location of the route in the gym (e.g., "Overhang Wall")</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="lane_id">Lane *</label>
                            </th>
                            <td>
                                <select name="lane_id" id="lane_id" required>
                                    <option value="">Select Lane</option>
                                    <?php foreach ($lanes as $lane): ?>
                                        <option value="<?php echo esc_attr($lane->id); ?>"
                                                <?php selected(isset($_POST['lane_id']) ? $_POST['lane_id'] : '', $lane->id); ?>>
                                            <?php echo esc_html($lane->name ? $lane->name : "Lane {$lane->number}"); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                                <p class="description">Select the lane number where the route is located</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="hold_color_id">Hold Color</label>
                            </th>
                            <td>
                                <select name="hold_color_id" id="hold_color_id">
                                    <option value="">No specific color</option>
                                    <?php foreach ($hold_colors as $color): ?>
                                        <option value="<?php echo esc_attr($color->id); ?>"
                                                style="background-color: <?php echo esc_attr($color->hex_code); ?>; color: <?php echo $color->hex_code === '#FFFFFF' || $color->hex_code === '#FFFF00' ? '#000000' : '#FFFFFF'; ?>;"
                                                <?php selected(isset($_POST['hold_color_id']) ? $_POST['hold_color_id'] : '', $color->id); ?>>
                                            <?php echo esc_html($color->name); ?>
                                        </option>
                                    <?php endforeach; ?>
                                </select>
                                <p class="description">Optional: Select the primary hold color for this route</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="description">Description</label>
                            </th>
                            <td>
                                <textarea name="description" id="description" rows="4" cols="50" class="large-text"><?php echo isset($_POST['description']) ? esc_textarea($_POST['description']) : ''; ?></textarea>
                                <p class="description">Optional: Add notes about the route (moves, beta, style, etc.)</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
                
                <p class="submit">
                    <input type="submit" name="submit" id="submit" class="button button-primary" value="Create Route" />
                    <a href="<?php echo admin_url('admin.php?page=crux-routes'); ?>" class="button">Cancel</a>
                </p>
            </form>
        </div>
        
        <div class="crux-help-sidebar">
            <div class="postbox">
                <h3 class="hndle">Route Creation Tips</h3>
                <div class="inside">
                    <ul>
                        <li><strong>Grade System:</strong> Uses French climbing grades (3a to 9c)</li>
                        <li><strong>Wall Sections:</strong> Common sections include Overhang, Slab, Vertical, Steep, Roof</li>
                        <li><strong>Lane Numbers:</strong> Corresponds to physical lane markers in the gym</li>
                        <li><strong>Hold Colors:</strong> Help climbers identify the route visually</li>
                        <li><strong>Descriptions:</strong> Include style notes, key moves, or beta</li>
                    </ul>
                </div>
            </div>
            
            <div class="postbox">
                <h3 class="hndle">Quick Stats</h3>
                <div class="inside">
                    <?php
                    global $wpdb;
                    $total_routes = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_routes");
                    $total_grades = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_grades");
                    $total_colors = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_hold_colors");
                    ?>
                    <p><strong>Total Routes:</strong> <?php echo $total_routes; ?></p>
                    <p><strong>Available Grades:</strong> <?php echo $total_grades; ?></p>
                    <p><strong>Hold Colors:</strong> <?php echo $total_colors; ?></p>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.crux-admin-content {
    display: flex;
    gap: 20px;
}

.crux-form-container {
    flex: 2;
}

.crux-help-sidebar {
    flex: 1;
    min-width: 300px;
}

.crux-add-route-form {
    background: #fff;
    padding: 20px;
    border: 1px solid #ccd0d4;
    box-shadow: 0 1px 1px rgba(0,0,0,.04);
}

.crux-add-route-form .form-table th {
    padding-left: 0;
}

#hold_color_id option {
    padding: 5px 10px;
    border-radius: 3px;
    margin: 1px 0;
}

.postbox {
    margin-bottom: 20px;
}

.postbox h3 {
    margin: 0;
    padding: 8px 12px;
    background: #f1f1f1;
    border-bottom: 1px solid #eee;
}

.postbox .inside {
    padding: 12px;
}

.postbox ul {
    margin: 0;
    padding-left: 20px;
}

.postbox li {
    margin-bottom: 8px;
}

@media (max-width: 782px) {
    .crux-admin-content {
        flex-direction: column;
    }
    
    .crux-help-sidebar {
        min-width: auto;
    }
}
</style>
