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
        'max_lanes_per_section' => intval($_POST['max_lanes_per_section'] ?? 20),
        'allow_public_registration' => isset($_POST['allow_public_registration']),
        'require_email_verification' => isset($_POST['require_email_verification']),
        'enable_route_rating' => isset($_POST['enable_route_rating']),
        'enable_route_comments' => isset($_POST['enable_route_comments']),
        'enable_route_photos' => isset($_POST['enable_route_photos']),
        'auto_archive_routes_days' => intval($_POST['auto_archive_routes_days'] ?? 0),
        'grade_system' => sanitize_text_field($_POST['grade_system'] ?? 'french'),
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
    'max_lanes_per_section' => 20,
    'allow_public_registration' => true,
    'require_email_verification' => false,
    'enable_route_rating' => true,
    'enable_route_comments' => true,
    'enable_route_photos' => true,
    'auto_archive_routes_days' => 0,
    'grade_system' => 'french',
);

$settings = wp_parse_args($settings, $defaults);

// Get wall sections and hold colors from database
$wall_sections = Crux_Wall_Section::get_all();
$hold_colors = Crux_Hold_Colors::get_all();
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

            <!-- Wall Sections Management -->
            <div class="postbox">
                <h2 class="hndle">Wall Sections Management</h2>
                <div class="inside">
                    <div class="crux-management-section">
                        <div class="add-item-form">
                            <h3>Add New Wall Section</h3>
                            <div class="form-row">
                                <input type="text" id="new_wall_section_name" placeholder="Wall section name" class="regular-text" />
                                <button type="button" class="button button-primary" id="add_wall_section_btn">Add Section</button>
                            </div>
                        </div>
                        
                        <div class="items-list">
                            <h3>Current Wall Sections</h3>
                            <ul id="wall_sections_list" class="crux-items-list">
                                <?php if (empty($wall_sections)): ?>
                                    <li class="empty-message">No wall sections yet. Add one above!</li>
                                <?php else: ?>
                                    <?php foreach ($wall_sections as $section): ?>
                                        <li class="crux-item" data-id="<?php echo esc_attr($section->id); ?>">
                                            <span class="item-name"><?php echo esc_html($section->name); ?></span>
                                            <button type="button" class="button button-small delete-wall-section" data-id="<?php echo esc_attr($section->id); ?>">Delete</button>
                                        </li>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Hold Colors Management -->
            <div class="postbox">
                <h2 class="hndle">Hold Colors Management</h2>
                <div class="inside">
                    <div class="crux-management-section">
                        <div class="add-item-form">
                            <h3>Add New Hold Color</h3>
                            <div class="form-row">
                                <input type="text" id="new_hold_color_name" placeholder="Color name" class="regular-text" />
                                <input type="color" id="new_hold_color_hex" value="#FF0000" />
                                <button type="button" class="button button-primary" id="add_hold_color_btn">Add Color</button>
                            </div>
                        </div>
                        
                        <div class="items-list">
                            <h3>Current Hold Colors</h3>
                            <ul id="hold_colors_list" class="crux-items-list">
                                <?php if (empty($hold_colors)): ?>
                                    <li class="empty-message">No hold colors yet. Add one above!</li>
                                <?php else: ?>
                                    <?php foreach ($hold_colors as $color): ?>
                                        <li class="crux-item" data-id="<?php echo esc_attr($color->id); ?>">
                                            <span class="color-swatch" style="background-color: <?php echo esc_attr($color->hex_code); ?>"></span>
                                            <span class="item-name"><?php echo esc_html($color->name); ?></span>
                                            <span class="item-hex"><?php echo esc_html($color->hex_code); ?></span>
                                            <button type="button" class="button button-small delete-hold-color" data-id="<?php echo esc_attr($color->id); ?>">Delete</button>
                                        </li>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Route Management -->
            <div class="postbox">
                <h2 class="hndle">Route Management</h2>
                <div class="inside">
                    <table class="form-table">
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

.crux-management-section {
    padding: 10px 0;
}

.add-item-form {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 4px;
    margin-bottom: 20px;
}

.add-item-form h3 {
    margin-top: 0;
    margin-bottom: 10px;
    font-size: 14px;
}

.form-row {
    display: flex;
    gap: 10px;
    align-items: center;
}

.form-row input[type="text"],
.form-row input[type="color"] {
    flex-shrink: 0;
}

.form-row input[type="color"] {
    width: 60px;
    height: 36px;
    border-radius: 3px;
    cursor: pointer;
}

.items-list h3 {
    margin-bottom: 10px;
    font-size: 14px;
}

.crux-items-list {
    list-style: none;
    margin: 0;
    padding: 0;
}

.crux-items-list .crux-item {
    display: flex;
    align-items: center;
    padding: 10px;
    background: white;
    border: 1px solid #ddd;
    border-radius: 3px;
    margin-bottom: 5px;
}

.crux-items-list .crux-item:hover {
    background: #f8f9fa;
}

.crux-items-list .color-swatch {
    width: 24px;
    height: 24px;
    border-radius: 3px;
    border: 1px solid #ddd;
    margin-right: 10px;
    flex-shrink: 0;
}

.crux-items-list .item-name {
    flex: 1;
    font-weight: 500;
}

.crux-items-list .item-hex {
    color: #666;
    font-size: 13px;
    margin-right: 10px;
    font-family: monospace;
}

.crux-items-list .empty-message {
    padding: 20px;
    text-align: center;
    color: #666;
    font-style: italic;
    background: #f8f9fa;
    border: 1px dashed #ddd;
    border-radius: 3px;
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

<script>
jQuery(document).ready(function($) {
    // Add wall section
    $('#add_wall_section_btn').on('click', function() {
        var name = $('#new_wall_section_name').val().trim();
        
        if (!name) {
            alert('Please enter a wall section name');
            return;
        }
        
        $.ajax({
            url: crux_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'crux_add_wall_section',
                nonce: crux_admin_ajax.nonce,
                name: name
            },
            success: function(response) {
                if (response.success) {
                    // Remove empty message if it exists
                    $('#wall_sections_list .empty-message').remove();
                    
                    // Add new item to list
                    var section = response.data.section;
                    var newItem = $('<li class="crux-item" data-id="' + section.id + '">' +
                        '<span class="item-name">' + escapeHtml(section.name) + '</span>' +
                        '<button type="button" class="button button-small delete-wall-section" data-id="' + section.id + '">Delete</button>' +
                        '</li>');
                    $('#wall_sections_list').append(newItem);
                    
                    // Clear input
                    $('#new_wall_section_name').val('');
                    
                    // Show success message
                    showNotice('Wall section added successfully!', 'success');
                } else {
                    alert('Error: ' + response.data.message);
                }
            },
            error: function() {
                alert('An error occurred. Please try again.');
            }
        });
    });
    
    // Delete wall section
    $(document).on('click', '.delete-wall-section', function() {
        if (!confirm('Are you sure you want to delete this wall section?')) {
            return;
        }
        
        var id = $(this).data('id');
        var $item = $(this).closest('.crux-item');
        
        $.ajax({
            url: crux_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'crux_delete_wall_section',
                nonce: crux_admin_ajax.nonce,
                id: id
            },
            success: function(response) {
                if (response.success) {
                    $item.fadeOut(300, function() {
                        $(this).remove();
                        
                        // Show empty message if no items left
                        if ($('#wall_sections_list .crux-item').length === 0) {
                            $('#wall_sections_list').html('<li class="empty-message">No wall sections yet. Add one above!</li>');
                        }
                    });
                    
                    showNotice('Wall section deleted successfully!', 'success');
                } else {
                    alert('Error: ' + response.data.message);
                }
            },
            error: function() {
                alert('An error occurred. Please try again.');
            }
        });
    });
    
    // Add hold color
    $('#add_hold_color_btn').on('click', function() {
        var name = $('#new_hold_color_name').val().trim();
        var hex_code = $('#new_hold_color_hex').val();
        
        if (!name) {
            alert('Please enter a color name');
            return;
        }
        
        $.ajax({
            url: crux_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'crux_add_hold_color',
                nonce: crux_admin_ajax.nonce,
                name: name,
                hex_code: hex_code
            },
            success: function(response) {
                if (response.success) {
                    // Remove empty message if it exists
                    $('#hold_colors_list .empty-message').remove();
                    
                    // Add new item to list
                    var color = response.data.color;
                    var newItem = $('<li class="crux-item" data-id="' + color.id + '">' +
                        '<span class="color-swatch" style="background-color: ' + escapeHtml(color.hex_code) + '"></span>' +
                        '<span class="item-name">' + escapeHtml(color.name) + '</span>' +
                        '<span class="item-hex">' + escapeHtml(color.hex_code) + '</span>' +
                        '<button type="button" class="button button-small delete-hold-color" data-id="' + color.id + '">Delete</button>' +
                        '</li>');
                    $('#hold_colors_list').append(newItem);
                    
                    // Clear input
                    $('#new_hold_color_name').val('');
                    
                    // Show success message
                    showNotice('Hold color added successfully!', 'success');
                } else {
                    alert('Error: ' + response.data.message);
                }
            },
            error: function() {
                alert('An error occurred. Please try again.');
            }
        });
    });
    
    // Delete hold color
    $(document).on('click', '.delete-hold-color', function() {
        if (!confirm('Are you sure you want to delete this hold color?')) {
            return;
        }
        
        var id = $(this).data('id');
        var $item = $(this).closest('.crux-item');
        
        $.ajax({
            url: crux_admin_ajax.ajax_url,
            type: 'POST',
            data: {
                action: 'crux_delete_hold_color',
                nonce: crux_admin_ajax.nonce,
                id: id
            },
            success: function(response) {
                if (response.success) {
                    $item.fadeOut(300, function() {
                        $(this).remove();
                        
                        // Show empty message if no items left
                        if ($('#hold_colors_list .crux-item').length === 0) {
                            $('#hold_colors_list').html('<li class="empty-message">No hold colors yet. Add one above!</li>');
                        }
                    });
                    
                    showNotice('Hold color deleted successfully!', 'success');
                } else {
                    alert('Error: ' + response.data.message);
                }
            },
            error: function() {
                alert('An error occurred. Please try again.');
            }
        });
    });
    
    // Helper function to escape HTML
    function escapeHtml(text) {
        var map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text.replace(/[&<>"']/g, function(m) { return map[m]; });
    }
    
    // Helper function to show WordPress notices
    function showNotice(message, type) {
        var $notice = $('<div class="notice notice-' + type + ' is-dismissible"><p>' + message + '</p></div>');
        $('.wrap h1').after($notice);
        
        // Auto-dismiss after 3 seconds
        setTimeout(function() {
            $notice.fadeOut(300, function() {
                $(this).remove();
            });
        }, 3000);
    }
});
</script>
