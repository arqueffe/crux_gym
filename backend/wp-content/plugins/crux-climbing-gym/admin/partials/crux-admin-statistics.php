<?php
/**
 * Statistics dashboard admin page
 *
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/admin/partials
 */

// If this file is called directly, abort.
if (!defined('WPINC')) {
    die;
}

// Get statistics data
global $wpdb;

// Routes statistics
$total_routes = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_routes WHERE active = 1");
$routes_by_grade = $wpdb->get_results("
    SELECT g.french_name as grade, COUNT(r.id) as count 
    FROM {$wpdb->prefix}crux_routes r 
    JOIN {$wpdb->prefix}crux_grades g ON r.grade_id = g.id 
    WHERE r.active = 1 
    GROUP BY r.grade_id 
    ORDER BY g.value ASC
");

// Users statistics
$total_users = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_users WHERE active = 1");
$new_users_this_month = $wpdb->get_var("
    SELECT COUNT(*) FROM {$wpdb->prefix}crux_users 
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
");

// Climbing statistics
$total_ticks = $wpdb->get_var("SELECT COUNT(*) FROM {$wpdb->prefix}crux_ticks");
$ticks_this_month = $wpdb->get_var("
    SELECT COUNT(*) FROM {$wpdb->prefix}crux_ticks 
    WHERE created_at >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
");

// Popular routes
$popular_routes = $wpdb->get_results("
    SELECT r.name, r.wall_section, g.french_name as grade, COUNT(t.id) as tick_count
    FROM {$wpdb->prefix}crux_routes r
    LEFT JOIN {$wpdb->prefix}crux_ticks t ON r.id = t.route_id
    LEFT JOIN {$wpdb->prefix}crux_grades g ON r.grade_id = g.id
    WHERE r.active = 1
    GROUP BY r.id
    HAVING tick_count > 0
    ORDER BY tick_count DESC
    LIMIT 10
");

// Grade distribution
$grade_colors = Crux_Grade::get_colors();
?>

<div class="wrap">
    <h1 class="wp-heading-inline">Climbing Gym Statistics</h1>
    <hr class="wp-header-end">

    <!-- Overview Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-number"><?php echo number_format($total_routes); ?></div>
            <div class="stat-label">Active Routes</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><?php echo number_format($total_users); ?></div>
            <div class="stat-label">Active Users</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><?php echo number_format($total_ticks); ?></div>
            <div class="stat-label">Total Climbs</div>
        </div>
        <div class="stat-card">
            <div class="stat-number"><?php echo number_format($ticks_this_month); ?></div>
            <div class="stat-label">Climbs This Month</div>
        </div>
    </div>

    <!-- Charts and Tables -->
    <div class="stats-content">
        <div class="stats-row">
            <!-- Routes by Grade -->
            <div class="stats-column">
                <div class="postbox">
                    <h2 class="hndle">Routes by Grade Distribution</h2>
                    <div class="inside">
                        <?php if (empty($routes_by_grade)): ?>
                            <p>No route data available.</p>
                        <?php else: ?>
                            <table class="wp-list-table widefat">
                                <thead>
                                    <tr>
                                        <th>Grade</th>
                                        <th>Routes</th>
                                        <th>Percentage</th>
                                        <th>Visual</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($routes_by_grade as $grade_stat): ?>
                                        <?php 
                                        $percentage = ($grade_stat->count / $total_routes) * 100;
                                        $color = isset($grade_colors[$grade_stat->grade]) ? $grade_colors[$grade_stat->grade] : '#cccccc';
                                        ?>
                                        <tr>
                                            <td>
                                                <span class="grade-badge" style="background-color: <?php echo esc_attr($color); ?>; color: white; padding: 2px 6px; border-radius: 3px; font-size: 12px; font-weight: 600;">
                                                    <?php echo esc_html($grade_stat->grade); ?>
                                                </span>
                                            </td>
                                            <td><?php echo esc_html($grade_stat->count); ?></td>
                                            <td><?php echo number_format($percentage, 1); ?>%</td>
                                            <td>
                                                <div class="progress-bar">
                                                    <div class="progress-fill" style="width: <?php echo $percentage; ?>%; background-color: <?php echo esc_attr($color); ?>;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- Popular Routes -->
            <div class="stats-column">
                <div class="postbox">
                    <h2 class="hndle">Most Popular Routes</h2>
                    <div class="inside">
                        <?php if (empty($popular_routes)): ?>
                            <p>No climbing data available yet.</p>
                        <?php else: ?>
                            <table class="wp-list-table widefat">
                                <thead>
                                    <tr>
                                        <th>Route Name</th>
                                        <th>Grade</th>
                                        <th>Wall Section</th>
                                        <th>Climbs</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($popular_routes as $route): ?>
                                        <?php 
                                        $color = isset($grade_colors[$route->grade]) ? $grade_colors[$route->grade] : '#cccccc';
                                        ?>
                                        <tr>
                                            <td><strong><?php echo esc_html($route->name); ?></strong></td>
                                            <td>
                                                <span class="grade-badge" style="background-color: <?php echo esc_attr($color); ?>; color: white; padding: 2px 6px; border-radius: 3px; font-size: 11px; font-weight: 600;">
                                                    <?php echo esc_html($route->grade); ?>
                                                </span>
                                            </td>
                                            <td><?php echo esc_html($route->wall_section ?: 'N/A'); ?></td>
                                            <td><strong><?php echo esc_html($route->tick_count); ?></strong></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>

        <!-- Monthly Activity -->
        <div class="stats-row">
            <div class="stats-full">
                <div class="postbox">
                    <h2 class="hndle">Recent Activity Summary</h2>
                    <div class="inside">
                        <div class="activity-summary">
                            <div class="activity-item">
                                <span class="activity-label">New Users This Month:</span>
                                <span class="activity-value"><?php echo number_format($new_users_this_month); ?></span>
                            </div>
                            <div class="activity-item">
                                <span class="activity-label">Climbs This Month:</span>
                                <span class="activity-value"><?php echo number_format($ticks_this_month); ?></span>
                            </div>
                            <div class="activity-item">
                                <span class="activity-label">Average Climbs per User:</span>
                                <span class="activity-value">
                                    <?php echo $total_users > 0 ? number_format($total_ticks / $total_users, 1) : '0'; ?>
                                </span>
                            </div>
                            <div class="activity-item">
                                <span class="activity-label">Routes Utilization:</span>
                                <span class="activity-value">
                                    <?php 
                                    $routes_with_ticks = $wpdb->get_var("SELECT COUNT(DISTINCT route_id) FROM {$wpdb->prefix}crux_ticks");
                                    $utilization = $total_routes > 0 ? ($routes_with_ticks / $total_routes) * 100 : 0;
                                    echo number_format($utilization, 1) . '%';
                                    ?>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin: 20px 0;
}

.stat-card {
    background: white;
    border: 1px solid #c3c4c7;
    border-radius: 4px;
    padding: 20px;
    text-align: center;
    box-shadow: 0 1px 1px rgba(0,0,0,0.04);
}

.stat-number {
    font-size: 36px;
    font-weight: 600;
    color: #0073aa;
    line-height: 1;
    margin-bottom: 5px;
}

.stat-label {
    font-size: 14px;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.stats-content {
    margin-top: 30px;
}

.stats-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 20px;
}

.stats-full {
    grid-column: 1 / -1;
}

.stats-column {
    min-width: 0;
}

.progress-bar {
    width: 100%;
    height: 10px;
    background-color: #f0f0f1;
    border-radius: 5px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    transition: width 0.3s ease;
}

.grade-badge {
    text-shadow: 1px 1px 1px rgba(0,0,0,0.3);
}

.activity-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
}

.activity-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 15px;
    background: #f8f9fa;
    border-radius: 4px;
    border-left: 4px solid #0073aa;
}

.activity-label {
    font-weight: 500;
    color: #666;
}

.activity-value {
    font-size: 18px;
    font-weight: 600;
    color: #0073aa;
}

@media (max-width: 768px) {
    .stats-row {
        grid-template-columns: 1fr;
    }
    
    .activity-summary {
        grid-template-columns: 1fr;
    }
}
</style>
