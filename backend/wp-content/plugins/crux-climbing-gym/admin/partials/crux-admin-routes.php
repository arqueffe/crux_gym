<?php

/**
 * Routes management admin page
 *
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/admin/partials
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

// Get routes data
$routes = Crux_Route::get_all();
$grades = Crux_Grade::get_all();
$hold_colors = Crux_Hold_Colors::get_all();
?>

<div class="wrap">
    <h1 class="wp-heading-inline">Climbing Routes</h1>
    <a href="<?php echo admin_url('admin.php?page=crux-add-route'); ?>" class="page-title-action">Add New Route</a>
    <hr class="wp-header-end">

    <?php if (empty($routes)): ?>
        <div class="notice notice-info">
            <p>No routes found. <a href="<?php echo admin_url('admin.php?page=crux-add-route'); ?>">Add your first route</a>!</p>
        </div>
    <?php else: ?>
        <table class="wp-list-table widefat fixed striped">
            <thead>
                <tr>
                    <th scope="col" class="manage-column">Name</th>
                    <th scope="col" class="manage-column">Grade</th>
                    <th scope="col" class="manage-column">Setter</th>
                    <th scope="col" class="manage-column">Wall Section</th>
                    <th scope="col" class="manage-column">Lane</th>
                    <th scope="col" class="manage-column">Color</th>
                    <th scope="col" class="manage-column">Created</th>
                    <th scope="col" class="manage-column">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($routes as $route): ?>
                    <tr>
                        <td class="title column-title">
                            <strong><?php echo esc_html($route->name); ?></strong>
                            <?php if ($route->description): ?>
                                <br><small class="description"><?php echo esc_html(wp_trim_words($route->description, 10)); ?></small>
                            <?php endif; ?>
                        </td>
                        <td>
                            <span class="grade-badge" style="background-color: <?php echo esc_attr($route->grade_color); ?>; color: white; padding: 2px 6px; border-radius: 3px;">
                                <?php echo esc_html($route->grade); ?>
                            </span>
                        </td>
                        <td><?php echo esc_html($route->route_setter); ?></td>
                        <td><?php echo esc_html($route->wall_section); ?></td>
                        <td>Lane <?php echo esc_html(isset($route->lane_id) ? $route->lane_id : 'N/A'); ?></td>
                        <td>
                            <?php if (isset($route->hold_color_id) && $route->hold_color_id): ?>
                                <span class="color-indicator" style="display: inline-block; width: 15px; height: 15px; border-radius: 50%; background-color:
                                <?php
                                $color = Crux_Hold_Colors::get_by_id($route->hold_color_id);
                                echo esc_attr($color ? $color['hex_code'] : '#000000');
                                ?>; border: 1px solid #ccc; vertical-align: middle;"></span>
                            <?php else: ?>
                                <span class="description">—</span>
                            <?php endif; ?>
                        </td>
                        <td><?php echo esc_html(date('Y-m-d', strtotime($route->created_at))); ?></td>
                        <td>
                            <form method="post" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this route? This action cannot be undone.');">
                                <?php wp_nonce_field('delete_route_' . $route->id); ?>
                                <input type="hidden" name="route_id" value="<?php echo esc_attr($route->id); ?>">
                                <input type="submit" name="delete_route" class="button button-small" value="Delete" style="color: #a00;">
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <div class="tablenav bottom">
            <div class="alignleft actions">
                <p class="description">Total routes: <?php echo count($routes); ?></p>
            </div>
        </div>
    <?php endif; ?>
</div>

<style>
    .grade-badge {
        font-weight: bold;
        font-size: 11px;
        text-transform: uppercase;
    }

    .color-indicator {
        margin-right: 5px;
    }

    .description {
        color: #666;
        font-style: italic;
    }
</style>