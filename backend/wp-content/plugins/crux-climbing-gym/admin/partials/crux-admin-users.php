<?php
/**
 * Users management admin page
 *
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/admin/partials
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

// Get users data
$users = Crux_User::get_all();
$user_stats = array();
foreach ($users as $user) {
    $user_stats[$user->id] = Crux_User::get_stats($user->id);
}
?>

<div class="wrap">
    <h1 class="wp-heading-inline">Climbing Gym Users</h1>
    <hr class="wp-header-end">
    
    <!-- Users Statistics Summary -->
    <div class="notice notice-info">
        <p><strong>Users Overview:</strong> Total Users: <?php echo count($users); ?> | Active Users: <?php echo count(array_filter($users, function($u) { return $u->active; })); ?></p>
    </div>

    <!-- Users Table -->
    <div class="users-list">
        <table class="wp-list-table widefat fixed striped">
            <thead>
                <tr>
                    <th scope="col" class="manage-column column-cb check-column">
                        <input type="checkbox" />
                    </th>
                    <th scope="col" class="manage-column">Username</th>
                    <th scope="col" class="manage-column">Email</th>
                    <th scope="col" class="manage-column">Full Name</th>
                    <th scope="col" class="manage-column">Climbs</th>
                    <th scope="col" class="manage-column">Favorite Grade</th>
                    <th scope="col" class="manage-column">Status</th>
                    <th scope="col" class="manage-column">Joined</th>
                    <th scope="col" class="manage-column">Last Login</th>
                    <th scope="col" class="manage-column">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($users)): ?>
                    <tr>
                        <td colspan="10">No users found.</td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($users as $user): ?>
                        <?php $stats = isset($user_stats[$user->id]) ? $user_stats[$user->id] : null; ?>
                        <tr>
                            <th scope="row" class="check-column">
                                <input type="checkbox" name="user[]" value="<?php echo esc_attr($user->id); ?>" />
                            </th>
                            <td class="column-username">
                                <strong>
                                    <a href="<?php echo admin_url('admin.php?page=crux-user-details&id=' . $user->id); ?>">
                                        <?php echo esc_html($user->username); ?>
                                    </a>
                                </strong>
                                <?php if ($user->admin): ?>
                                    <br><span class="admin-badge">Admin</span>
                                <?php endif; ?>
                            </td>
                            <td class="column-email">
                                <a href="mailto:<?php echo esc_attr($user->email); ?>"><?php echo esc_html($user->email); ?></a>
                            </td>
                            <td class="column-fullname">
                                <?php echo esc_html($user->first_name . ' ' . $user->last_name); ?>
                            </td>
                            <td class="column-climbs">
                                <?php if ($stats): ?>
                                    <strong><?php echo esc_html($stats['total_ticks']); ?></strong> climbs
                                    <?php if ($stats['total_ticks'] > 0): ?>
                                        <br><small>Avg grade: <?php echo esc_html($stats['average_grade'] ?: 'N/A'); ?></small>
                                    <?php endif; ?>
                                <?php else: ?>
                                    0 climbs
                                <?php endif; ?>
                            </td>
                            <td class="column-favorite-grade">
                                <?php if ($stats && $stats['favorite_grade']): ?>
                                    <span class="grade-badge" style="background-color: <?php echo esc_attr($stats['favorite_grade_color'] ?: '#cccccc'); ?>; color: white; padding: 2px 6px; border-radius: 3px; font-size: 12px;">
                                        <?php echo esc_html($stats['favorite_grade']); ?>
                                    </span>
                                <?php else: ?>
                                    N/A
                                <?php endif; ?>
                            </td>
                            <td class="column-status">
                                <?php 
                                $status = $user->active ? 'Active' : 'Inactive';
                                $status_class = $user->active ? 'status-active' : 'status-inactive';
                                echo '<span class="' . esc_attr($status_class) . '">' . esc_html($status) . '</span>';
                                ?>
                            </td>
                            <td class="column-joined">
                                <?php echo esc_html(date('Y-m-d', strtotime($user->created_at))); ?>
                            </td>
                            <td class="column-last-login">
                                <?php 
                                if ($user->last_login) {
                                    echo esc_html(date('Y-m-d H:i', strtotime($user->last_login)));
                                } else {
                                    echo 'Never';
                                }
                                ?>
                            </td>
                            <td class="column-actions">
                                <a href="<?php echo admin_url('admin.php?page=crux-user-details&id=' . $user->id); ?>" class="button button-small">View</a>
                                <?php if (!$user->admin): ?>
                                    <a href="<?php echo admin_url('admin.php?page=crux-users&action=toggle-status&id=' . $user->id); ?>" 
                                       class="button button-small">
                                        <?php echo $user->active ? 'Deactivate' : 'Activate'; ?>
                                    </a>
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

    <!-- User Management Actions -->
    <div class="tablenav bottom">
        <div class="alignleft actions bulkactions">
            <label for="bulk-action-selector-bottom" class="screen-reader-text">Select bulk action</label>
            <select name="action2" id="bulk-action-selector-bottom">
                <option value="-1">Bulk Actions</option>
                <option value="activate">Activate</option>
                <option value="deactivate">Deactivate</option>
                <option value="export">Export User Data</option>
            </select>
            <input type="submit" id="doaction2" class="button action" value="Apply">
        </div>
        <div class="alignright">
            <span class="displaying-num"><?php echo count($users); ?> users</span>
        </div>
    </div>
</div>

<style>
.status-active {
    color: #46b450;
    font-weight: 600;
}

.status-inactive {
    color: #dc3232;
    font-weight: 600;
}

.admin-badge {
    background-color: #0073aa;
    color: white;
    padding: 2px 6px;
    border-radius: 3px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
}

.grade-badge {
    font-weight: 600;
    text-shadow: 1px 1px 1px rgba(0,0,0,0.3);
}

.users-list {
    margin-top: 20px;
}

.column-climbs strong {
    color: #0073aa;
}

.column-climbs small {
    color: #666;
}
</style>
