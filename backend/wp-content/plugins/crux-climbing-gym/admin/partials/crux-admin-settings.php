<?php
/**
 * Plugin settings admin page
 *
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/admin/partials
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

// Handle form submission
if (isset($_POST['submit']) && wp_verify_nonce($_POST['crux_settings_nonce'], 'crux_settings')) {
    $settings = array(
        'gym_name' => sanitize_text_field($_POST['gym_name'] ?? ''),
        'gym_address' => sanitize_textarea_field($_POST['gym_address'] ?? ''),
        'gym_phone' => sanitize_text_field($_POST['gym_phone'] ?? ''),
        'gym_email' => sanitize_email($_POST['gym_email'] ?? ''),
        'gym_website' => esc_url_raw($_POST['gym_website'] ?? ''),
        'default_wall_sections' => sanitize_textarea_field($_POST['default_wall_sections'] ?? ''),
        'max_lanes_per_section' => intval($_POST['max_lanes_per_section'] ?? 20),
        'allow_public_registration' => isset($_POST['allow_public_registration']),
        'require_email_verification' => isset($_POST['require_email_verification']),
        'enable_route_rating' => isset($_POST['enable_route_rating']),
        'enable_route_comments' => isset($_POST['enable_route_comments']),
        'enable_route_photos' => isset($_POST['enable_route_photos']),
        'auto_archive_routes_days' => intval($_POST['auto_archive_routes_days'] ?? 0),
        'grade_system' => sanitize_text_field($_POST['grade_system'] ?? 'french'),
        'default_hold_colors' => sanitize_textarea_field($_POST['default_hold_colors'] ?? ''),
    );
    
    update_option('crux_climbing_gym_settings', $settings);
    
    echo '<div class="notice notice-success"><p>Settings saved successfully!</p></div>';
}

// Get current settings
$settings = get_option('crux_climbing_gym_settings', array());
$defaults = array(
    'gym_name' => get_bloginfo('name'),
    'gym_address' => '',
    'gym_phone' => '',
    'gym_email' => get_option('admin_email'),
    'gym_website' => home_url(),
    'default_wall_sections' => "Main Wall\nOverhang\nSlab\nTraverse Wall\nKids Wall\nTraining Area",
    'max_lanes_per_section' => 20,
    'allow_public_registration' => true,
    'require_email_verification' => false,
    'enable_route_rating' => true,
    'enable_route_comments' => true,
    'enable_route_photos' => true,
    'auto_archive_routes_days' => 0,
    'grade_system' => 'french',
    'default_hold_colors' => "#FF0000 Red\n#00FF00 Green\n#0000FF Blue\n#FFFF00 Yellow\n#FF8000 Orange\n#800080 Purple\n#FFC0CB Pink\n#000000 Black\n#FFFFFF White\n#808080 Gray",
);

$settings = wp_parse_args($settings, $defaults);
?>

<div class="wrap">
    <h1 class="wp-heading-inline">Climbing Gym Settings</h1>
    <hr class="wp-header-end">

    <form method="post" action="">
        <?php wp_nonce_field('crux_settings', 'crux_settings_nonce'); ?>
        
        <div class="settings-sections">
            <!-- Gym Information -->
            <div class="postbox">
                <h2 class="hndle">Gym Information</h2>
                <div class="inside">
                    <table class="form-table">
                        <tr>
                            <th scope="row"><label for="gym_name">Gym Name</label></th>
                            <td>
                                <input type="text" id="gym_name" name="gym_name" value="<?php echo esc_attr($settings['gym_name']); ?>" class="regular-text" />
                                <p class="description">The name of your climbing gym.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="gym_address">Address</label></th>
                            <td>
                                <textarea id="gym_address" name="gym_address" rows="3" class="large-text"><?php echo esc_textarea($settings['gym_address']); ?></textarea>
                                <p class="description">Full address of your climbing gym.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="gym_phone">Phone Number</label></th>
                            <td>
                                <input type="text" id="gym_phone" name="gym_phone" value="<?php echo esc_attr($settings['gym_phone']); ?>" class="regular-text" />
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="gym_email">Contact Email</label></th>
                            <td>
                                <input type="email" id="gym_email" name="gym_email" value="<?php echo esc_attr($settings['gym_email']); ?>" class="regular-text" />
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="gym_website">Website</label></th>
                            <td>
                                <input type="url" id="gym_website" name="gym_website" value="<?php echo esc_attr($settings['gym_website']); ?>" class="regular-text" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- Route Management -->
            <div class="postbox">
                <h2 class="hndle">Route Management</h2>
                <div class="inside">
                    <table class="form-table">
                        <tr>
                            <th scope="row"><label for="default_wall_sections">Wall Sections</label></th>
                            <td>
                                <textarea id="default_wall_sections" name="default_wall_sections" rows="6" class="large-text"><?php echo esc_textarea($settings['default_wall_sections']); ?></textarea>
                                <p class="description">List of wall sections, one per line. These will be available when adding routes.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="max_lanes_per_section">Max Lanes per Section</label></th>
                            <td>
                                <input type="number" id="max_lanes_per_section" name="max_lanes_per_section" value="<?php echo esc_attr($settings['max_lanes_per_section']); ?>" min="1" max="100" class="small-text" />
                                <p class="description">Maximum number of lanes available in each wall section.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="grade_system">Grade System</label></th>
                            <td>
                                <select id="grade_system" name="grade_system">
                                    <option value="french" <?php selected($settings['grade_system'], 'french'); ?>>French (3a, 3b, 3c...)</option>
                                    <option value="yds" <?php selected($settings['grade_system'], 'yds'); ?>>YDS (5.5, 5.6, 5.7...)</option>
                                    <option value="v-scale" <?php selected($settings['grade_system'], 'v-scale'); ?>>V-Scale (V0, V1, V2...)</option>
                                </select>
                                <p class="description">Primary grading system for routes.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="default_hold_colors">Default Hold Colors</label></th>
                            <td>
                                <textarea id="default_hold_colors" name="default_hold_colors" rows="6" class="large-text"><?php echo esc_textarea($settings['default_hold_colors']); ?></textarea>
                                <p class="description">Available hold colors, format: "#HEX Color Name" one per line.</p>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row"><label for="auto_archive_routes_days">Auto-Archive Routes</label></th>
                            <td>
                                <input type="number" id="auto_archive_routes_days" name="auto_archive_routes_days" value="<?php echo esc_attr($settings['auto_archive_routes_days']); ?>" min="0" class="small-text" />
                                <span> days</span>
                                <p class="description">Automatically archive routes after this many days (0 = disabled).</p>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- User Features -->
            <div class="postbox">
                <h2 class="hndle">User Features</h2>
                <div class="inside">
                    <table class="form-table">
                        <tr>
                            <th scope="row">Registration</th>
                            <td>
                                <fieldset>
                                    <label>
                                        <input type="checkbox" name="allow_public_registration" value="1" <?php checked($settings['allow_public_registration']); ?> />
                                        Allow public user registration
                                    </label>
                                    <br>
                                    <label>
                                        <input type="checkbox" name="require_email_verification" value="1" <?php checked($settings['require_email_verification']); ?> />
                                        Require email verification
                                    </label>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <th scope="row">Route Interaction</th>
                            <td>
                                <fieldset>
                                    <label>
                                        <input type="checkbox" name="enable_route_rating" value="1" <?php checked($settings['enable_route_rating']); ?> />
                                        Enable route rating/stars
                                    </label>
                                    <br>
                                    <label>
                                        <input type="checkbox" name="enable_route_comments" value="1" <?php checked($settings['enable_route_comments']); ?> />
                                        Enable route comments
                                    </label>
                                    <br>
                                    <label>
                                        <input type="checkbox" name="enable_route_photos" value="1" <?php checked($settings['enable_route_photos']); ?> />
                                        Enable route photos
                                    </label>
                                </fieldset>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <!-- API Settings -->
            <div class="postbox">
                <h2 class="hndle">API Information</h2>
                <div class="inside">
                    <p>The REST API is automatically enabled when this plugin is active. Here are the key endpoints:</p>
                    <ul class="api-endpoints">
                        <li><code><?php echo home_url('/wp-json/crux/v1/auth/register'); ?></code> - User registration</li>
                        <li><code><?php echo home_url('/wp-json/crux/v1/auth/login'); ?></code> - User login</li>
                        <li><code><?php echo home_url('/wp-json/crux/v1/routes'); ?></code> - Routes listing</li>
                        <li><code><?php echo home_url('/wp-json/crux/v1/user/stats'); ?></code> - User statistics</li>
                    </ul>
                    <p><strong>API Documentation:</strong> <a href="<?php echo admin_url('admin.php?page=crux-api-docs'); ?>">View full API documentation</a></p>
                </div>
            </div>
        </div>

        <?php submit_button('Save Settings'); ?>
    </form>
</div>

<style>
.settings-sections {
    margin-top: 20px;
}

.settings-sections .postbox {
    margin-bottom: 20px;
}

.settings-sections .postbox .inside {
    padding: 12px;
}

.api-endpoints {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 4px;
    border-left: 4px solid #0073aa;
}

.api-endpoints li {
    margin-bottom: 8px;
}

.api-endpoints code {
    background: white;
    padding: 4px 8px;
    border-radius: 3px;
    border: 1px solid #ddd;
    font-size: 13px;
}

.form-table th {
    width: 200px;
}

.form-table .description {
    margin-top: 5px;
    color: #666;
    font-size: 13px;
}

fieldset label {
    margin-bottom: 8px;
    display: block;
}

fieldset input[type="checkbox"] {
    margin-right: 8px;
}
</style>
