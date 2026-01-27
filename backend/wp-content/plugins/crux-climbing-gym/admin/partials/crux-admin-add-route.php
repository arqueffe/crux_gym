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
                                <label for="route_name">Route Name</label>
                            </th>
                            <td>
                                <input name="route_name" type="text" id="route_name" 
                                       value="<?php echo isset($_POST['route_name']) ? esc_attr($_POST['route_name']) : ''; ?>" 
                                       class="regular-text" />
                                <label style="display: block; margin-top: 8px;">
                                    <input type="checkbox" name="unnamed_route" id="unnamed_route" value="1"
                                           <?php checked(isset($_POST['unnamed_route']), true); ?> />
                                    Leave unnamed (route will be named "Unnamed" until users propose names)
                                </label>
                                <p class="description">Enter a creative name for the climbing route, or check the box above to leave it unnamed</p>
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
                                <input name="route_image" type="file" id="route_image" accept="image/*" />
                                <input name="route_image_edited" type="hidden" id="route_image_edited" />
                                <p class="description">Picture of this route</p>
                                
                                <!-- Image Editor -->
                                <div id="image-editor-container" style="display:none; margin-top: 20px; border: 2px solid #ddd; padding: 20px; background: #f9f9f9;">
                                    <h3>Image Editor</h3>
                                    
                                    <!-- Editor Toolbar -->
                                    <div class="image-editor-toolbar" style="margin-bottom: 15px; padding: 10px; background: #fff; border: 1px solid #ddd;">
                                        <button type="button" class="button" id="tool-crop">
                                            <span class="dashicons dashicons-image-crop"></span> Crop
                                        </button>
                                        <button type="button" class="button" id="tool-holds">
                                            <span class="dashicons dashicons-marker"></span> Highlight Holds
                                        </button>
                                        <button type="button" class="button" id="tool-crux">
                                            <span class="dashicons dashicons-image-filter"></span> Highlight Crux
                                        </button>
                                        <button type="button" class="button" id="tool-clip">
                                            <span class="dashicons dashicons-location"></span> Mark Clips
                                        </button>
                                        <button type="button" class="button" id="tool-reset">
                                            <span class="dashicons dashicons-image-rotate"></span> Reset
                                        </button>
                                        
                                        <span style="border-left: 1px solid #ddd; margin: 0 10px; padding-left: 10px;">
                                            <button type="button" class="button" id="zoom-out" title="Zoom Out">
                                                <span class="dashicons dashicons-minus"></span>
                                            </button>
                                            <span id="zoom-level" style="display: inline-block; min-width: 50px; text-align: center;">100%</span>
                                            <button type="button" class="button" id="zoom-in" title="Zoom In">
                                                <span class="dashicons dashicons-plus"></span>
                                            </button>
                                            <button type="button" class="button" id="zoom-reset" title="Reset Zoom">
                                                <span class="dashicons dashicons-image-flip-horizontal"></span>
                                            </button>
                                        </span>
                                        
                                        <button type="button" class="button button-primary" id="apply-edits" style="float: right;">
                                            <span class="dashicons dashicons-yes"></span> Apply & Save
                                        </button>
                                        <button type="button" class="button" id="cancel-edits" style="float: right; margin-right: 5px;">
                                            Cancel
                                        </button>
                                    </div>
                                    
                                    <!-- Tool Options -->
                                    <div id="tool-options" style="margin-bottom: 10px; padding: 10px; background: #fff; border: 1px solid #ddd; display: none;">
                                        <!-- Hold Options -->
                                        <div id="holds-options" style="display: none;">
                                            <p><em>Click and drag to create circles - drag further for larger circles<br>
                                            Left-click and drag existing circles to move them<br>
                                            Right-click on a circle to remove it</em></p>
                                            <button type="button" class="button button-small" id="clear-holds">Clear All Holds</button>
                                        </div>
                                        
                                        <!-- Crux Options -->
                                        <div id="crux-options" style="display: none;">
                                            <p><em>Click and drag to draw a rectangle highlighting the crux section</em></p>
                                            <button type="button" class="button button-small" id="clear-crux">Clear Crux</button>
                                        </div>
                                        
                                        <!-- Clip Options -->
                                        <div id="clip-options" style="display: none;">
                                            <p><em>Click to place clips. Left-click and drag to move. Right-click to remove.</em></p>
                                            <button type="button" class="button button-small" id="clear-clips">Clear All Clips</button>
                                        </div>
                                        
                                        <!-- Crop Options -->
                                        <div id="crop-options" style="display: none;">
                                            <p><em>Drag the blue borders inward to crop the image</em></p>
                                            <button type="button" class="button button-small" id="reset-crop-borders">Reset Borders</button>
                                            <button type="button" class="button button-primary button-small" id="apply-crop">Apply Crop</button>
                                        </div>
                                    </div>
                                    
                                    <!-- Canvas Container -->
                                    <div id="canvas-container" style="position: relative; display: inline-block; max-width: 100%; max-height: 600px; overflow: auto; background: #333; border: 2px solid #ddd;">
                                        <canvas id="image-editor-canvas" style="display: block; cursor: crosshair;"></canvas>
                                    </div>
                                    
                                    <p class="description" style="margin-top: 10px;">
                                        <strong>Instructions:</strong><br>
                                        • <strong>Zoom:</strong> Use +/- buttons or Ctrl+Mouse Wheel to zoom in/out for precise placement<br>
                                        • <strong></strong>Crop:</strong> Drag the blue borders inward to select crop area, then click "Apply Crop"<br>
                                        • <strong>Highlight Holds:</strong> Click and drag to create circles. Drag existing circles to move. Right-click to remove.<br>
                                        • <strong>Highlight Crux:</strong> Draw a rectangle around the crux section<br>
                                        • <strong>Mark Clips:</strong> Click to place clips. Drag to move them. Right-click to remove.
                                    </p>
                                </div>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="route_setter">Route Setter *</label>
                            </th>
                            <td>
                                <select name="route_setter_select" id="route_setter_select">
                                    <option value="">Select Existing Setter</option>
                                    <?php foreach ($route_setters as $setter): ?>
                                        <option value="<?php echo esc_attr($setter); ?>">
                                            <?php echo esc_html($setter); ?>
                                        </option>
                                    <?php endforeach; ?>
                                    <option value="__custom__">+ Add New Setter</option>
                                </select>
                                <input name="route_setter" type="text" id="route_setter_custom" 
                                       value="<?php echo isset($_POST['route_setter']) ? esc_attr($_POST['route_setter']) : ''; ?>" 
                                       class="regular-text" style="display:none; margin-top: 8px;" 
                                       placeholder="Enter new setter name" />
                                <p class="description">Select an existing setter or add a new one</p>
                            </td>
                        </tr>
                        
                        <tr>
                            <th scope="row">
                                <label for="wall_section">Wall Section *</label>
                            </th>
                            <td>
                                <select name="wall_section" id="wall_section" required>
                                    <option value="">Select Wall Section</option>
                                    <?php if (empty($wall_sections)): ?>
                                        <option value="" disabled>No wall sections found - add one in Settings</option>
                                    <?php else: ?>
                                        <?php foreach ($wall_sections as $section): ?>
                                            <option value="<?php echo esc_attr($section->name); ?>"
                                                    <?php selected(isset($_POST['wall_section']) ? $_POST['wall_section'] : '', $section->name); ?>>
                                                <?php echo esc_html($section->name); ?>
                                            </option>
                                        <?php endforeach; ?>
                                    <?php endif; ?>
                                </select>
                                <p class="description">Select the wall section where the route is located</p>
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

<script type="text/javascript">
jQuery(document).ready(function($) {
    // Image Editor Variables
    let canvas, ctx, canvasContainer;
    let originalImage = null;
    let currentTool = null;
    let editData = {
        holds: [],
        crux: null,
        clips: [],
        cropBorders: { top: 0, right: 0, bottom: 0, left: 0 } // pixels from edge
    };
    let isDrawing = false;
    let startX, startY;
    let tempRect = null;
    let tempHold = null; // For hold being created
    let draggedBorder = null;
    let draggedClipIndex = null; // For moving clips
    let draggedHoldIndex = null; // For moving holds
    let borderGrabZone = 20; // pixels around border to grab
    let clipGrabRadius = 20; // pixels around clip center to grab
    let zoomLevel = 1.0;
    let zoomMin = 0.5;
    let zoomMax = 3.0;
    let zoomStep = 0.25;
    
    // Initialize Canvas
    function initCanvas() {
        canvas = document.getElementById('image-editor-canvas');
        canvasContainer = document.getElementById('canvas-container');
        if (canvas) {
            ctx = canvas.getContext('2d');
            console.log('Canvas initialized:', canvas.width, 'x', canvas.height);
        }
    }
    
    // Handle Image Upload
    $('#route_image').on('change', function(e) {
        const file = e.target.files[0];
        if (!file) return;
        
        const reader = new FileReader();
        reader.onload = function(event) {
            const img = new Image();
            img.onload = function() {
                originalImage = img;
                console.log('Image loaded:', img.width, 'x', img.height);
                $('#image-editor-container').show();
                
                // Initialize canvas after showing container
                initCanvas();
                setupCanvasEvents();
                resetEditor();
                renderCanvas();
            };
            img.src = event.target.result;
        };
        reader.readAsDataURL(file);
    });
    
    // Reset Editor
    function resetEditor() {
        editData = {
            holds: [],
            crux: null,
            clips: [],
            cropBorders: { top: 0, right: 0, bottom: 0, left: 0 }
        };
        tempRect = null;
        tempHold = null;
        draggedBorder = null;
        draggedClipIndex = null;
        draggedHoldIndex = null;
        selectTool(null);
    }
    
    $('#tool-reset').on('click', resetEditor);
    
    // Render Canvas
    function renderCanvas() {
        if (!originalImage) return;
        
        // Set canvas size based on zoom
        const maxWidth = 800;
        const scale = Math.min(1, maxWidth / originalImage.width);
        canvas.width = originalImage.width * scale;
        canvas.height = originalImage.height * scale;
        
        // Apply zoom through CSS transform
        canvas.style.transform = `scale(${zoomLevel})`;
        canvas.style.transformOrigin = 'top left';
        
        // Update container dimensions to accommodate zoomed canvas
        canvasContainer.style.width = (canvas.width * zoomLevel) + 'px';
        canvasContainer.style.height = (canvas.height * zoomLevel) + 'px';
        
        // Clear canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        // Draw original image
        ctx.drawImage(originalImage, 0, 0, canvas.width, canvas.height);
        
        // Draw hold circles outline (no dark overlay)
        editData.holds.forEach(hold => {
            ctx.strokeStyle = '#ffeb3b';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.arc(hold.x, hold.y, hold.radius, 0, Math.PI * 2);
            ctx.stroke();
        });
        
        // Draw crux rectangle
        if (editData.crux) {
            ctx.strokeStyle = '#ff5722';
            ctx.lineWidth = 4;
            ctx.setLineDash([10, 5]);
            ctx.strokeRect(editData.crux.x, editData.crux.y, editData.crux.width, editData.crux.height);
            ctx.setLineDash([]);
            
            // Semi-transparent fill
            ctx.fillStyle = 'rgba(255, 87, 34, 0.2)';
            ctx.fillRect(editData.crux.x, editData.crux.y, editData.crux.width, editData.crux.height);
        }
        
        // Draw crop borders
        if (currentTool === 'crop') {
            const b = editData.cropBorders;
            ctx.strokeStyle = '#2196f3';
            ctx.lineWidth = 4;
            ctx.setLineDash([]);
            
            // Draw borders
            ctx.strokeRect(b.left, b.top, canvas.width - b.left - b.right, canvas.height - b.top - b.bottom);
            
            // Draw handles on corners and midpoints for grabbing
            ctx.fillStyle = '#2196f3';
            const handleSize = 12;
            const cropX = b.left;
            const cropY = b.top;
            const cropW = canvas.width - b.left - b.right;
            const cropH = canvas.height - b.top - b.bottom;
            
            // Corner handles
            ctx.fillRect(cropX - handleSize/2, cropY - handleSize/2, handleSize, handleSize);
            ctx.fillRect(cropX + cropW - handleSize/2, cropY - handleSize/2, handleSize, handleSize);
            ctx.fillRect(cropX - handleSize/2, cropY + cropH - handleSize/2, handleSize, handleSize);
            ctx.fillRect(cropX + cropW - handleSize/2, cropY + cropH - handleSize/2, handleSize, handleSize);
            
            // Dim the cropped-out areas
            ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
            if (b.top > 0) ctx.fillRect(0, 0, canvas.width, b.top); // Top
            if (b.bottom > 0) ctx.fillRect(0, canvas.height - b.bottom, canvas.width, b.bottom); // Bottom
            if (b.left > 0) ctx.fillRect(0, b.top, b.left, cropH); // Left
            if (b.right > 0) ctx.fillRect(canvas.width - b.right, b.top, b.right, cropH); // Right
        }
        
        // Draw temporary rectangle (for crux)
        if (tempRect && currentTool === 'crux') {
            ctx.strokeStyle = '#ff5722';
            ctx.lineWidth = 3;
            ctx.setLineDash([5, 5]);
            ctx.strokeRect(tempRect.x, tempRect.y, tempRect.width, tempRect.height);
            ctx.setLineDash([]);
        }
        
        // Draw clip symbols
        editData.clips.forEach(clip => {
            ctx.font = '30px Arial';
            ctx.fillStyle = '#fff';
            ctx.strokeStyle = '#000';
            ctx.lineWidth = 2;
            ctx.strokeText(clip.symbol, clip.x - 15, clip.y + 10);
            ctx.fillText(clip.symbol, clip.x - 15, clip.y + 10);
        });
        
        // Draw temporary hold being created
        if (tempHold) {
            ctx.strokeStyle = '#ffeb3b';
            ctx.lineWidth = 3;
            ctx.setLineDash([5, 5]);
            ctx.beginPath();
            ctx.arc(tempHold.x, tempHold.y, tempHold.radius, 0, Math.PI * 2);
            ctx.stroke();
            ctx.setLineDash([]);
            
            // Show radius text
            ctx.fillStyle = '#ffeb3b';
            ctx.font = '14px Arial';
            ctx.fillText(Math.round(tempHold.radius) + 'px', tempHold.x + tempHold.radius + 10, tempHold.y);
        }
    }
    
    // Tool Selection
    function selectTool(tool) {
        currentTool = tool;
        $('.image-editor-toolbar .button').removeClass('button-primary');
        $('#tool-options > div').hide();
        
        if (tool) {
            $(`#tool-${tool}`).addClass('button-primary');
            $(`#${tool}-options`).show();
            $('#tool-options').show();
        } else {
            $('#tool-options').hide();
        }
        
        // Update cursor
        if (tool) {
            canvas.style.cursor = 'crosshair';
        } else {
            canvas.style.cursor = 'default';
        }
        
        renderCanvas();
    }
    
    $('#tool-crop').on('click', () => selectTool('crop'));
    $('#tool-holds').on('click', () => selectTool('holds'));
    $('#tool-crux').on('click', () => selectTool('crux'));
    $('#tool-clip').on('click', () => selectTool('clip'));
    
    // Note: hold-radius control removed - now using click and drag
    
    // Canvas Mouse Events
    function getMousePos(e) {
        const rect = canvas.getBoundingClientRect();
        const scaleX = canvas.width / rect.width;
        const scaleY = canvas.height / rect.height;
        return {
            x: (e.clientX - rect.left) * scaleX,
            y: (e.clientY - rect.top) * scaleY
        };
    }
    
    // Zoom functions
    function updateZoomDisplay() {
        $('#zoom-level').text(Math.round(zoomLevel * 100) + '%');
    }
    
    function setZoom(newZoom) {
        zoomLevel = Math.max(zoomMin, Math.min(zoomMax, newZoom));
        updateZoomDisplay();
        renderCanvas();
    }
    
    $('#zoom-in').on('click', function() {
        setZoom(zoomLevel + zoomStep);
    });
    
    $('#zoom-out').on('click', function() {
        setZoom(zoomLevel - zoomStep);
    });
    
    $('#zoom-reset').on('click', function() {
        setZoom(1.0);
    });
    
    // Mouse wheel zoom
    $(canvasContainer).on('wheel', function(e) {
        if (e.ctrlKey || e.metaKey) {
            e.preventDefault();
            const delta = e.originalEvent.deltaY;
            if (delta < 0) {
                setZoom(zoomLevel + zoomStep);
            } else {
                setZoom(zoomLevel - zoomStep);
            }
        }
    });
    
    function setupCanvasEvents() {
        if (!canvas) {
            console.error('Canvas not found, cannot setup events');
            return;
        }
        
        console.log('Setting up canvas events');
        
        // Remove any existing handlers to avoid duplicates
        $(canvas).off('mousedown mousemove mouseup contextmenu');
        
        // Prevent context menu on canvas
        $(canvas).on('contextmenu', function(e) {
            e.preventDefault();
            return false;
        });
        
        $(canvas).on('mousedown', function(e) {
            console.log('Mouse down, tool:', currentTool);
            if (!currentTool) {
                console.log('No tool selected');
                return;
            }
            
            const pos = getMousePos(e);
            console.log('Click position:', pos);
            startX = pos.x;
            startY = pos.y;
            
            if (currentTool === 'crop') {
                // Check which border is being grabbed
                const b = editData.cropBorders;
                const zone = borderGrabZone;
                
                // Check if near borders
                if (Math.abs(pos.y - b.top) < zone && pos.x > b.left && pos.x < canvas.width - b.right) {
                    draggedBorder = 'top';
                    isDrawing = true;
                } else if (Math.abs(pos.y - (canvas.height - b.bottom)) < zone && pos.x > b.left && pos.x < canvas.width - b.right) {
                    draggedBorder = 'bottom';
                    isDrawing = true;
                } else if (Math.abs(pos.x - b.left) < zone && pos.y > b.top && pos.y < canvas.height - b.bottom) {
                    draggedBorder = 'left';
                    isDrawing = true;
                } else if (Math.abs(pos.x - (canvas.width - b.right)) < zone && pos.y > b.top && pos.y < canvas.height - b.bottom) {
                    draggedBorder = 'right';
                    isDrawing = true;
                }
            } else if (currentTool === 'holds') {
                // Check if right-click to remove a hold
                if (e.which === 3) {
                    // Right-click: check if clicking on an existing hold
                    let removedHold = false;
                    for (let i = editData.holds.length - 1; i >= 0; i--) {
                        const hold = editData.holds[i];
                        const dx = pos.x - hold.x;
                        const dy = pos.y - hold.y;
                        const distance = Math.sqrt(dx * dx + dy * dy);
                        
                        if (distance <= hold.radius) {
                            // Remove this hold
                            editData.holds.splice(i, 1);
                            removedHold = true;
                            renderCanvas();
                            break;
                        }
                    }
                    if (removedHold) return;
                }
                
                // Left-click: Check if clicking on existing hold to move it
                for (let i = 0; i < editData.holds.length; i++) {
                    const hold = editData.holds[i];
                    const dx = pos.x - hold.x;
                    const dy = pos.y - hold.y;
                    const distance = Math.sqrt(dx * dx + dy * dy);
                    
                    if (distance <= hold.radius) {
                        // Start dragging this hold
                        draggedHoldIndex = i;
                        isDrawing = true;
                        return;
                    }
                }
                
                // Left-click on empty space: Start creating a new hold circle
                console.log('Starting hold at', pos);
                isDrawing = true;
                tempHold = {
                    x: pos.x,
                    y: pos.y,
                    radius: 10 // Minimum radius
                };
                renderCanvas();
        } else if (currentTool === 'clip') {
                // Check if right-click to remove a clip
                if (e.which === 3) {
                    for (let i = editData.clips.length - 1; i >= 0; i--) {
                        const clip = editData.clips[i];
                        const dx = Math.abs(pos.x - clip.x);
                        const dy = Math.abs(pos.y - clip.y);
                        
                        if (dx < clipGrabRadius && dy < clipGrabRadius) {
                            editData.clips.splice(i, 1);
                            renderCanvas();
                            return;
                        }
                    }
                    return;
                }
                
                // Check if left-click on existing clip to move it
                for (let i = 0; i < editData.clips.length; i++) {
                    const clip = editData.clips[i];
                    const dx = Math.abs(pos.x - clip.x);
                    const dy = Math.abs(pos.y - clip.y);
                    
                    if (dx < clipGrabRadius && dy < clipGrabRadius) {
                        // Start dragging this clip
                        draggedClipIndex = i;
                        isDrawing = true;
                        return;
                    }
                }
                
                // Add new clip symbol
                editData.clips.push({
                    x: pos.x,
                    y: pos.y,
                    symbol: '●'
                });
                renderCanvas();
            } else if (currentTool === 'crux') {
            isDrawing = true;
            tempRect = { x: startX, y: startY, width: 0, height: 0 };
        }
    });
    
    $(canvas).on('mousemove', function(e) {
        const pos = getMousePos(e);
        
        // Update cursor for crop tool
        if (currentTool === 'crop' && !isDrawing) {
            const b = editData.cropBorders;
            const zone = borderGrabZone;
            let cursor = 'default';
            
            if (Math.abs(pos.y - b.top) < zone && pos.x > b.left && pos.x < canvas.width - b.right) {
                cursor = 'ns-resize';
            } else if (Math.abs(pos.y - (canvas.height - b.bottom)) < zone && pos.x > b.left && pos.x < canvas.width - b.right) {
                cursor = 'ns-resize';
            } else if (Math.abs(pos.x - b.left) < zone && pos.y > b.top && pos.y < canvas.height - b.bottom) {
                cursor = 'ew-resize';
            } else if (Math.abs(pos.x - (canvas.width - b.right)) < zone && pos.y > b.top && pos.y < canvas.height - b.bottom) {
                cursor = 'ew-resize';
            }
            
            canvas.style.cursor = cursor;
        }
        
        // Update cursor for holds tool - show pointer when over a hold
        if (currentTool === 'holds' && !isDrawing) {
            let overHold = false;
            for (let i = 0; i < editData.holds.length; i++) {
                const hold = editData.holds[i];
                const dx = pos.x - hold.x;
                const dy = pos.y - hold.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                
                if (distance <= hold.radius) {
                    overHold = true;
                    break;
                }
            }
            canvas.style.cursor = overHold ? 'move' : 'crosshair';
        }
        
        // Update cursor for clips tool - show move cursor when over a clip
        if (currentTool === 'clip' && !isDrawing) {
            let overClip = false;
            for (let i = 0; i < editData.clips.length; i++) {
                const clip = editData.clips[i];
                const dx = Math.abs(pos.x - clip.x);
                const dy = Math.abs(pos.y - clip.y);
                
                if (dx < clipGrabRadius && dy < clipGrabRadius) {
                    overClip = true;
                    break;
                }
            }
            canvas.style.cursor = overClip ? 'move' : 'crosshair';
        }
        
        if (!isDrawing) return;
        
        if (currentTool === 'crop' && draggedBorder) {
            // Update the border being dragged
            const b = editData.cropBorders;
            const maxTop = canvas.height - b.bottom - 50;
            const maxBottom = canvas.height - b.top - 50;
            const maxLeft = canvas.width - b.right - 50;
            const maxRight = canvas.width - b.left - 50;
            
            switch(draggedBorder) {
                case 'top':
                    editData.cropBorders.top = Math.max(0, Math.min(pos.y, maxTop));
                    break;
                case 'bottom':
                    editData.cropBorders.bottom = Math.max(0, Math.min(canvas.height - pos.y, maxBottom));
                    break;
                case 'left':
                    editData.cropBorders.left = Math.max(0, Math.min(pos.x, maxLeft));
                    break;
                case 'right':
                    editData.cropBorders.right = Math.max(0, Math.min(canvas.width - pos.x, maxRight));
                    break;
            }
            renderCanvas();
        } else if (currentTool === 'crux' && tempRect) {
            tempRect.width = pos.x - startX;
            tempRect.height = pos.y - startY;
            renderCanvas();
        } else if (currentTool === 'holds' && tempHold) {
            // Calculate radius based on distance from center
            const dx = pos.x - tempHold.x;
            const dy = pos.y - tempHold.y;
            const distance = Math.sqrt(dx * dx + dy * dy);
            tempHold.radius = Math.max(10, distance); // Minimum 10px
            renderCanvas();
        } else if (currentTool === 'holds' && draggedHoldIndex !== null) {
            // Move the dragged hold
            editData.holds[draggedHoldIndex].x = pos.x;
            editData.holds[draggedHoldIndex].y = pos.y;
            renderCanvas();
        } else if (currentTool === 'clip' && draggedClipIndex !== null) {
            // Move the dragged clip
            editData.clips[draggedClipIndex].x = pos.x;
            editData.clips[draggedClipIndex].y = pos.y;
            renderCanvas();
        }
    });
    
    $(canvas).on('mouseup', function(e) {
        if (!isDrawing) return;
        isDrawing = false;
        
        if (currentTool === 'crop') {
            draggedBorder = null;
        } else if (currentTool === 'clip' && draggedClipIndex !== null) {
            // Finished moving clip
            draggedClipIndex = null;
        } else if (currentTool === 'holds' && draggedHoldIndex !== null) {
            // Finished moving hold
            draggedHoldIndex = null;
        } else if (currentTool === 'holds' && tempHold) {
            // Finalize the hold
            if (tempHold.radius >= 10) {
                editData.holds.push({
                    x: tempHold.x,
                    y: tempHold.y,
                    radius: tempHold.radius
                });
            }
            tempHold = null;
            renderCanvas();
        } else if (currentTool === 'crux' && tempRect) {
            // Normalize rectangle (handle negative width/height)
            const x = tempRect.width < 0 ? startX + tempRect.width : startX;
            const y = tempRect.height < 0 ? startY + tempRect.height : startY;
            const width = Math.abs(tempRect.width);
            const height = Math.abs(tempRect.height);
            
            editData.crux = { x, y, width, height };
            tempRect = null;
            renderCanvas();
        }
    });
    }
    
    // Clear Functions
    $('#clear-holds').on('click', function() {
        editData.holds = [];
        renderCanvas();
    });
    
    $('#clear-crux').on('click', function() {
        editData.crux = null;
        tempRect = null;
        renderCanvas();
    });
    
    $('#clear-clips').on('click', function() {
        editData.clips = [];
        renderCanvas();
    });
    
    $('#reset-crop-borders').on('click', function() {
        editData.cropBorders = { top: 0, right: 0, bottom: 0, left: 0 };
        renderCanvas();
    });
    
    // Apply Crop
    $('#apply-crop').on('click', function() {
        const b = editData.cropBorders;
        
        // Check if there's anything to crop
        if (b.top === 0 && b.right === 0 && b.bottom === 0 && b.left === 0) {
            alert('No crop applied. Drag the borders inward first.');
            return;
        }
        
        // Calculate crop dimensions
        const cropX = b.left;
        const cropY = b.top;
        const cropWidth = canvas.width - b.left - b.right;
        const cropHeight = canvas.height - b.top - b.bottom;
        
        // Create new cropped image
        const croppedCanvas = document.createElement('canvas');
        croppedCanvas.width = cropWidth;
        croppedCanvas.height = cropHeight;
        const croppedCtx = croppedCanvas.getContext('2d');
        
        // Draw cropped portion
        croppedCtx.drawImage(canvas, cropX, cropY, cropWidth, cropHeight, 0, 0, cropWidth, cropHeight);
        
        // Update original image
        const img = new Image();
        img.onload = function() {
            originalImage = img;
            
            // Adjust edit data coordinates
            editData.holds = editData.holds.map(hold => ({
                x: hold.x - cropX,
                y: hold.y - cropY,
                radius: hold.radius
            })).filter(hold => hold.x >= 0 && hold.x <= cropWidth && hold.y >= 0 && hold.y <= cropHeight);
            
            if (editData.crux) {
                editData.crux = {
                    x: editData.crux.x - cropX,
                    y: editData.crux.y - cropY,
                    width: editData.crux.width,
                    height: editData.crux.height
                };
            }
            
            editData.clips = editData.clips.map(clip => ({
                x: clip.x - cropX,
                y: clip.y - cropY,
                symbol: clip.symbol
            })).filter(clip => clip.x >= 0 && clip.x <= cropWidth && clip.y >= 0 && clip.y <= cropHeight);
            
            // Reset crop borders
            editData.cropBorders = { top: 0, right: 0, bottom: 0, left: 0 };
            tempRect = null;
            selectTool(null);
            renderCanvas();
        };
        img.src = croppedCanvas.toDataURL();
    });
    
    // Apply & Save Edits
    $('#apply-edits').on('click', function() {
        if (!originalImage) return;
        
        // Create final canvas with all edits
        const finalCanvas = document.createElement('canvas');
        finalCanvas.width = canvas.width;
        finalCanvas.height = canvas.height;
        const finalCtx = finalCanvas.getContext('2d');
        
        // Draw the current canvas state
        finalCtx.drawImage(canvas, 0, 0);
        
        // Convert to blob and store
        finalCanvas.toBlob(function(blob) {
            // Create a File object
            const file = new File([blob], 'edited-route-image.png', { type: 'image/png' });
            
            // Store edited image data as base64
            const dataURL = finalCanvas.toDataURL('image/png');
            $('#route_image_edited').val(dataURL);
            
            alert('Image edits applied! The edited image will be uploaded when you create the route.');
            $('#image-editor-container').hide();
        });
    });
    
    $('#cancel-edits').on('click', function() {
        $('#image-editor-container').hide();
        $('#route_image').val('');
        $('#route_image_edited').val('');
    });
    
    // Note: Canvas will be initialized when image is loaded
    
    // Handle route setter selection
    $('#route_setter_select').on('change', function() {
        var value = $(this).val();
        var $customInput = $('#route_setter_custom');
        
        if (value === '__custom__') {
            // Show custom input and require it
            $customInput.show().prop('required', true);
            $customInput.val('');
            $(this).prop('required', false);
        } else {
            // Hide custom input and use selected value
            $customInput.hide().prop('required', false);
            $customInput.val(value);
            $(this).prop('required', true);
        }
    });
    
    // Handle unnamed route checkbox
    $('#unnamed_route').on('change', function() {
        var $routeNameInput = $('#route_name');
        if ($(this).is(':checked')) {
            // Disable and clear route name field when unnamed is checked
            $routeNameInput.prop('required', false).prop('disabled', true).val('');
        } else {
            // Enable route name field when unnamed is unchecked
            $routeNameInput.prop('required', false).prop('disabled', false);
        }
    });
    
    // Initialize on page load
    $('#route_setter_select').trigger('change');
    $('#unnamed_route').trigger('change');
});
</script>
