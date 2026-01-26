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

// Group routes by lane
$routes_by_lane = [];
$lane_numbers = [];
foreach ($routes as $route) {
    $lane = isset($route->lane_id) ? $route->lane_id : 0;
    if (!isset($routes_by_lane[$lane])) {
        $routes_by_lane[$lane] = [];
        $lane_numbers[] = $lane;
    }
    $routes_by_lane[$lane][] = $route;
}
sort($lane_numbers);
?>

<div class="wrap crux-routes-wrap">
    <h1 class="wp-heading-inline">Climbing Routes</h1>
    <a href="<?php echo admin_url('admin.php?page=crux-add-route'); ?>" class="page-title-action">Add New Route</a>
    <hr class="wp-header-end">

    <?php if (empty($routes)): ?>
        <div class="notice notice-info">
            <p>No routes found. <a href="<?php echo admin_url('admin.php?page=crux-add-route'); ?>">Add your first route</a>!</p>
        </div>
    <?php else: ?>
        <div class="crux-lanes-container">
            <?php foreach ($lane_numbers as $lane): ?>
                <div class="crux-lane-column">
                    <div class="crux-lane-header">
                        <h2>Lane <?php echo esc_html($lane == 0 ? 'N/A' : $lane); ?></h2>
                        <span class="crux-lane-count"><?php echo count($routes_by_lane[$lane]); ?> routes</span>
                    </div>
                    
                    <div class="crux-routes-list">
                        <?php foreach ($routes_by_lane[$lane] as $route): ?>
                            <div class="crux-route-card" data-route-id="<?php echo esc_attr($route->id); ?>">
                                <div class="crux-route-header">
                                    <h3 class="crux-route-name"><?php echo esc_html($route->name); ?></h3>
                                    <?php if (isset($route->hold_color_id) && $route->hold_color_id): ?>
                                        <span class="crux-color-indicator" style="background-color:
                                        <?php
                                        $color = Crux_Hold_Colors::get_by_id($route->hold_color_id);
                                        echo esc_attr($color ? $color['hex_code'] : '#000000');
                                        ?>;"></span>
                                    <?php endif; ?>
                                </div>
                                <?php if (isset($route->image)): ?>
                                    <div class="crux-route-image">
                                        <img title="<?php echo esc_html($route->image); ?>" src="<?php echo esc_html($route->image); ?>">
                                    </div>
                                <?php endif; ?>
                                
                                <?php if ($route->description): ?>
                                    <p class="crux-route-description"><?php echo esc_html(wp_trim_words($route->description, 15)); ?></p>
                                <?php endif; ?>
                                
                                <div class="crux-route-meta">
                                    <div class="crux-meta-item">
                                        <?php if (isset($route->grade_id) && $route->grade_id): ?>
                                            <?php 
                                                $grade = Crux_Grade::get_by_id($route->grade_id);
                                            ?>
                                            <span class="crux-grade-badge" style="background-color: <?php echo esc_attr($grade ? $grade['color'] : '#000'); ?>;">
                                                <?php echo esc_html($grade ? $grade['french_name'] : 'N/A'); ?>
                                            </span>
                                        <?php else: ?>
                                            <span class="crux-grade-badge crux-no-grade">No grade</span>
                                        <?php endif; ?>
                                    </div>
                                    <div class="crux-meta-item">
                                        <strong>Setter:</strong> <?php echo esc_html($route->route_setter); ?>
                                    </div>
                                    <div class="crux-meta-item">
                                        <strong>Wall:</strong> <?php echo esc_html($route->wall_section); ?>
                                    </div>
                                    <div class="crux-meta-item">
                                        <strong>Created:</strong> <?php echo esc_html(date('M j, Y', strtotime($route->created_at))); ?>
                                    </div>
                                </div>
                                
                                <div class="crux-route-actions">
                                    <button class="crux-btn crux-btn-rename" onclick="cruxRenameRoute(<?php echo esc_js($route->id); ?>, '<?php echo esc_js($route->name); ?>')">
                                        <span class="dashicons dashicons-edit"></span> Rename
                                    </button>
                                    <button class="crux-btn crux-btn-modify" onclick="cruxModifyRoute(<?php echo esc_js($route->id); ?>)">
                                        <span class="dashicons dashicons-admin-settings"></span> Modify
                                    </button>
                                    <button class="crux-btn crux-btn-delete" onclick="cruxDeleteRoute(<?php echo esc_js($route->id); ?>, '<?php echo esc_js($route->name); ?>')">
                                        <span class="dashicons dashicons-trash"></span> Delete
                                    </button>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <div class="crux-stats-bar">
            <div class="crux-stat">
                <strong>Total Routes:</strong> <?php echo count($routes); ?>
            </div>
            <div class="crux-stat">
                <strong>Total Lanes:</strong> <?php echo count($lane_numbers); ?>
            </div>
        </div>
    <?php endif; ?>
</div>

<!-- Delete Confirmation Modal -->
<div id="crux-delete-modal" class="crux-modal" style="display: none;">
    <div class="crux-modal-overlay" onclick="cruxCloseDeleteModal()"></div>
    <div class="crux-modal-content">
        <div class="crux-modal-header">
            <span class="dashicons dashicons-warning crux-warning-icon"></span>
            <h2>⚠️ DELETE ROUTE - WARNING ⚠️</h2>
        </div>
        <div class="crux-modal-body">
            <p class="crux-warning-text">You are about to permanently delete:</p>
            <p class="crux-route-name-display" id="crux-delete-route-name"></p>
            <p class="crux-danger-text">
                <strong>THIS ACTION CANNOT BE UNDONE!</strong><br>
                All data associated with this route will be permanently lost.
            </p>
            <p>Are you absolutely sure you want to continue?</p>
        </div>
        <div class="crux-modal-actions">
            <button class="crux-btn crux-btn-cancel" onclick="cruxCloseDeleteModal()">
                Cancel
            </button>
            <form method="post" id="crux-delete-form" style="display: inline;">
                <input type="hidden" name="route_id" id="crux-delete-route-id">
                <input type="hidden" id="crux-delete-nonce" name="_wpnonce">
                <button type="submit" name="delete_route" class="crux-btn crux-btn-delete-confirm">
                    <span class="dashicons dashicons-trash"></span> YES, DELETE PERMANENTLY
                </button>
            </form>
        </div>
    </div>
</div>

<style>
    .crux-routes-wrap {
        background: #f5f5f5;
        margin: -10px -20px;
        padding: 20px;
    }
    
    .crux-routes-wrap h1 {
        margin-bottom: 20px;
    }
    
    .crux-lanes-container {
        display: flex;
        gap: 20px;
        overflow-x: auto;
        padding: 20px 0;
        margin-bottom: 20px;
    }
    
    .crux-lane-column {
        min-width: 320px;
        max-width: 320px;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        overflow: hidden;
    }
    
    .crux-lane-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 15px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .crux-lane-header h2 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
    }
    
    .crux-lane-count {
        background: rgba(255,255,255,0.2);
        padding: 4px 12px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .crux-routes-list {
        padding: 15px;
        max-height: 70vh;
        overflow-y: auto;
    }
    
    .crux-route-card {
        background: #f9f9f9;
        border: 1px solid #e0e0e0;
        border-radius: 6px;
        padding: 15px;
        margin-bottom: 15px;
        transition: all 0.3s ease;
    }
    
    .crux-route-card:hover {
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        transform: translateY(-2px);
    }
    
    .crux-route-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
    }
    
    .crux-route-name {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
        color: #2c3e50;
        flex: 1;
    }
    
    .crux-route-image {
        text-align: center;
    }
    .crux-route-image img {
        display: inline-block;
        height:100px;
        max-width:100px;
        max-height:100px
    }
    
    .crux-color-indicator {
        width: 24px;
        height: 24px;
        border-radius: 50%;
        border: 2px solid #fff;
        box-shadow: 0 0 0 1px #ccc;
        flex-shrink: 0;
        margin-left: 10px;
    }
    
    .crux-route-description {
        color: #666;
        font-size: 13px;
        margin: 0 0 12px 0;
        line-height: 1.4;
    }
    
    .crux-route-meta {
        border-top: 1px solid #e0e0e0;
        padding-top: 10px;
        margin-bottom: 12px;
    }
    
    .crux-meta-item {
        font-size: 12px;
        color: #555;
        margin-bottom: 6px;
    }
    
    .crux-meta-item strong {
        color: #333;
    }
    
    .crux-grade-badge {
        display: inline-block;
        color: white;
        padding: 4px 10px;
        border-radius: 4px;
        font-weight: 700;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .crux-grade-badge.crux-no-grade {
        background-color: #95a5a6;
    }
    
    .crux-route-actions {
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
        margin-top: 12px;
    }
    
    .crux-btn {
        flex: 1;
        min-width: 80px;
        padding: 8px 12px;
        border: none;
        border-radius: 4px;
        font-size: 12px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
    }
    
    .crux-btn .dashicons {
        font-size: 16px;
        width: 16px;
        height: 16px;
    }
    
    .crux-btn-rename {
        background: #3498db;
        color: white;
    }
    
    .crux-btn-rename:hover {
        background: #2980b9;
    }
    
    .crux-btn-modify {
        background: #f39c12;
        color: white;
    }
    
    .crux-btn-modify:hover {
        background: #e67e22;
    }
    
    .crux-btn-delete {
        background: #e74c3c;
        color: white;
    }
    
    .crux-btn-delete:hover {
        background: #c0392b;
    }
    
    .crux-stats-bar {
        background: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        display: flex;
        gap: 30px;
    }
    
    .crux-stat {
        font-size: 14px;
        color: #555;
    }
    
    .crux-stat strong {
        color: #2c3e50;
    }
    
    /* Modal Styles */
    .crux-modal {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 100000;
    }
    
    .crux-modal-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.7);
    }
    
    .crux-modal-content {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        border-radius: 12px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        max-width: 500px;
        width: 90%;
        animation: crux-modal-appear 0.3s ease;
    }
    
    @keyframes crux-modal-appear {
        from {
            opacity: 0;
            transform: translate(-50%, -45%);
        }
        to {
            opacity: 1;
            transform: translate(-50%, -50%);
        }
    }
    
    .crux-modal-header {
        background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);
        color: white;
        padding: 20px;
        border-radius: 12px 12px 0 0;
        text-align: center;
        position: relative;
    }
    
    .crux-warning-icon {
        font-size: 48px;
        width: 48px;
        height: 48px;
        color: #fff;
        animation: crux-pulse 2s ease-in-out infinite;
    }
    
    @keyframes crux-pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.6; }
    }
    
    .crux-modal-header h2 {
        margin: 10px 0 0 0;
        font-size: 22px;
        font-weight: 700;
    }
    
    .crux-modal-body {
        padding: 30px;
        text-align: center;
    }
    
    .crux-warning-text {
        font-size: 16px;
        color: #555;
        margin-bottom: 10px;
    }
    
    .crux-route-name-display {
        font-size: 20px;
        font-weight: 700;
        color: #2c3e50;
        background: #f9f9f9;
        padding: 15px;
        border-radius: 6px;
        margin: 15px 0;
        border: 2px solid #e74c3c;
    }
    
    .crux-danger-text {
        background: #fee;
        border: 2px solid #e74c3c;
        border-radius: 6px;
        padding: 15px;
        margin: 15px 0;
        color: #c0392b;
        font-weight: 600;
        line-height: 1.6;
    }
    
    .crux-modal-actions {
        padding: 0 30px 30px;
        display: flex;
        gap: 15px;
        justify-content: center;
    }
    
    .crux-btn-cancel {
        background: #95a5a6;
        color: white;
        padding: 12px 24px;
        font-size: 14px;
    }
    
    .crux-btn-cancel:hover {
        background: #7f8c8d;
    }
    
    .crux-btn-delete-confirm {
        background: #e74c3c;
        color: white;
        padding: 12px 24px;
        font-size: 14px;
        font-weight: 700;
    }
    
    .crux-btn-delete-confirm:hover {
        background: #c0392b;
    }
    
    /* Scrollbar styling */
    .crux-routes-list::-webkit-scrollbar {
        width: 8px;
    }
    
    .crux-routes-list::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 4px;
    }
    
    .crux-routes-list::-webkit-scrollbar-thumb {
        background: #888;
        border-radius: 4px;
    }
    
    .crux-routes-list::-webkit-scrollbar-thumb:hover {
        background: #555;
    }
</style>

<script>
function cruxRenameRoute(routeId, currentName) {
    const newName = prompt('Enter new name for route:', currentName);
    if (newName && newName !== currentName) {
        // TODO: Implement rename functionality via AJAX
        alert('Rename functionality to be implemented. New name: ' + newName);
    }
}

function cruxModifyRoute(routeId) {
    // TODO: Redirect to edit page or open modal
    alert('Modify functionality to be implemented for route ID: ' + routeId);
}

function cruxDeleteRoute(routeId, routeName) {
    const modal = document.getElementById('crux-delete-modal');
    const routeNameDisplay = document.getElementById('crux-delete-route-name');
    const routeIdInput = document.getElementById('crux-delete-route-id');
    const nonceInput = document.getElementById('crux-delete-nonce');
    
    routeNameDisplay.textContent = routeName;
    routeIdInput.value = routeId;
    
    // Set nonce value
    <?php foreach ($routes as $route): ?>
    if (routeId === <?php echo $route->id; ?>) {
        nonceInput.value = '<?php echo wp_create_nonce('delete_route_' . $route->id); ?>';
    }
    <?php endforeach; ?>
    
    modal.style.display = 'block';
}

function cruxCloseDeleteModal() {
    const modal = document.getElementById('crux-delete-modal');
    modal.style.display = 'none';
}

// Close modal on escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        cruxCloseDeleteModal();
    }
});
</script>