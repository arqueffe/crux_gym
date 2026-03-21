<?php
/**
 * Routes import admin page
 *
 * @package    Crux_Climbing_Gym
 * @subpackage Crux_Climbing_Gym/admin/partials
 */

if (!defined('WPINC')) {
    die;
}
?>

<div class="wrap">
    <h1>Import Routes</h1>

    <?php if (!empty($imported_count)): ?>
        <div class="notice notice-success is-dismissible">
            <p><?php echo esc_html($imported_count); ?> route(s) imported successfully.</p>
        </div>
    <?php endif; ?>

    <?php if (!empty($import_notices)): ?>
        <div class="notice notice-success is-dismissible">
            <ul>
                <?php foreach ($import_notices as $notice): ?>
                    <li><?php echo esc_html($notice); ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>

    <?php if (!empty($import_errors)): ?>
        <div class="notice notice-error">
            <p><strong>Import errors:</strong></p>
            <ul>
                <?php foreach ($import_errors as $error): ?>
                    <li><?php echo esc_html($error); ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>

    <div class="card" style="max-width: none;">
        <h2>Step 1 — Upload JSON</h2>
        <p>Upload a routes JSON file. Supported formats: direct routes array, <code>{"routes": [...]}</code>, or phpMyAdmin export containing <code>wp_crux_routes</code>.</p>
        <form method="post" enctype="multipart/form-data">
            <?php wp_nonce_field('crux_import_routes_parse', 'crux_import_routes_nonce'); ?>
            <input type="file" name="routes_json_file" accept="application/json,.json" required>
            <button type="submit" name="crux_import_parse" class="button button-primary">Load for review</button>
        </form>
    </div>

    <?php if (!empty($parsed_routes)): ?>
        <div class="card" style="max-width: none; margin-top: 16px;">
            <h2>Step 2 — Review and edit before import</h2>
            <p>All values below are editable. Disable rows you do not want to import.</p>

            <form method="post" enctype="multipart/form-data">
                <?php wp_nonce_field('crux_import_routes_submit', 'crux_import_routes_submit_nonce'); ?>

                <?php if (!empty($available_images)): ?>
                    <?php foreach ($available_images as $available_image): ?>
                        <input type="hidden" name="available_images[]" value="<?php echo esc_attr($available_image); ?>">
                    <?php endforeach; ?>
                <?php endif; ?>

                <div style="margin: 10px 0 14px 0; padding: 10px; border: 1px solid #dcdcde; background: #fff;">
                    <label for="route_images" style="font-weight: 600; display:block; margin-bottom: 8px;">Upload Images for This Import</label>
                    <input type="file" id="route_images" name="route_images[]" accept="image/*" multiple>
                    <button type="submit" name="crux_import_upload_images" class="button" style="margin-left: 8px;">Upload images</button>
                    <p class="description" style="margin-top: 8px;">
                        Uploaded images appear in the Image dropdown for each route.
                        <?php if (!empty($available_images)): ?>
                            Currently available: <?php echo esc_html(count($available_images)); ?> image(s).
                        <?php endif; ?>
                    </p>
                </div>

                <p style="margin: 10px 0;">
                    <button type="button" class="button" id="crux-select-all-routes">Select all</button>
                    <button type="button" class="button" id="crux-unselect-all-routes">Unselect all</button>
                </p>

                <div style="overflow-x: auto; margin-top: 12px;">
                    <table class="widefat striped" style="min-width: 1400px;">
                        <thead>
                            <tr>
                                <th>Import</th>
                                <th>Source</th>
                                <th>Name</th>
                                <th>Grade</th>
                                <th>Setter</th>
                                <th>Wall</th>
                                <th>Lane</th>
                                <th>Hold Color</th>
                                <th>Image URL</th>
                                <th>Description</th>
                                <th>Active</th>
                                <th>Created At</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($parsed_routes as $index => $route): ?>
                                <tr>
                                    <td>
                                        <input type="hidden" name="route_rows[<?php echo esc_attr($index); ?>][enabled]" value="0">
                                        <input type="checkbox" class="crux-import-enabled" name="route_rows[<?php echo esc_attr($index); ?>][enabled]" value="1" <?php checked(intval($route['enabled']) === 1); ?>>
                                    </td>
                                    <td>
                                        <?php echo esc_html($route['_row_label']); ?>
                                    </td>
                                    <td>
                                        <input type="text" name="route_rows[<?php echo esc_attr($index); ?>][name]" value="<?php echo esc_attr($route['name']); ?>" class="regular-text" style="min-width: 180px;">
                                    </td>
                                    <td>
                                        <select name="route_rows[<?php echo esc_attr($index); ?>][grade_id]">
                                            <option value="">Select</option>
                                            <?php foreach ($grades as $grade): ?>
                                                <option value="<?php echo esc_attr($grade->id); ?>" <?php selected(intval($route['grade_id']), intval($grade->id)); ?>>
                                                    <?php echo esc_html($grade->french_name); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </td>
                                    <td>
                                        <input type="text" name="route_rows[<?php echo esc_attr($index); ?>][route_setter]" value="<?php echo esc_attr($route['route_setter']); ?>" class="regular-text" style="min-width: 150px;">
                                    </td>
                                    <td>
                                        <select name="route_rows[<?php echo esc_attr($index); ?>][wall_section]">
                                            <option value="">Select</option>
                                            <?php foreach ($wall_sections as $section): ?>
                                                <option value="<?php echo esc_attr($section->name); ?>" <?php selected($route['wall_section'], $section->name); ?>>
                                                    <?php echo esc_html($section->name); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </td>
                                    <td>
                                        <select name="route_rows[<?php echo esc_attr($index); ?>][lane_id]">
                                            <option value="">Select</option>
                                            <?php foreach ($lanes as $lane): ?>
                                                <option value="<?php echo esc_attr($lane->id); ?>" <?php selected(intval($route['lane_id']), intval($lane->id)); ?>>
                                                    <?php echo esc_html($lane->name ? $lane->name : "Lane {$lane->id}"); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </td>
                                    <td>
                                        <select name="route_rows[<?php echo esc_attr($index); ?>][hold_color_id]">
                                            <option value="">None</option>
                                            <?php foreach ($hold_colors as $color): ?>
                                                <option value="<?php echo esc_attr($color->id); ?>" <?php selected((string) $route['hold_color_id'], (string) $color->id); ?>>
                                                    <?php echo esc_html($color->name); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </td>
                                    <td>
                                        <?php
                                        $row_image = isset($route['image']) ? (string) $route['image'] : '';
                                        $row_image_options = !empty($available_images) ? $available_images : array();
                                        if (!empty($row_image) && !in_array($row_image, $row_image_options, true)) {
                                            $row_image_options[] = $row_image;
                                        }
                                        ?>
                                        <select name="route_rows[<?php echo esc_attr($index); ?>][image]" style="min-width: 260px;">
                                            <option value="">None</option>
                                            <?php foreach ($row_image_options as $image_url): ?>
                                                <?php
                                                $image_path = parse_url($image_url, PHP_URL_PATH);
                                                $image_label = $image_path ? basename($image_path) : $image_url;
                                                ?>
                                                <option value="<?php echo esc_attr($image_url); ?>" <?php selected($row_image, $image_url); ?>>
                                                    <?php echo esc_html($image_label); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                    </td>
                                    <td>
                                        <textarea name="route_rows[<?php echo esc_attr($index); ?>][description]" rows="2" style="min-width: 240px;"><?php echo esc_textarea($route['description']); ?></textarea>
                                    </td>
                                    <td>
                                        <select name="route_rows[<?php echo esc_attr($index); ?>][active]">
                                            <option value="1" <?php selected(intval($route['active']), 1); ?>>Yes</option>
                                            <option value="0" <?php selected(intval($route['active']), 0); ?>>No</option>
                                        </select>
                                    </td>
                                    <td>
                                        <input type="text" name="route_rows[<?php echo esc_attr($index); ?>][created_at]" value="<?php echo esc_attr($route['created_at']); ?>" class="regular-text" style="min-width: 170px;">
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>

                <p style="margin-top: 16px;">
                    <button type="submit" name="crux_import_submit" class="button button-primary">Import reviewed routes</button>
                </p>
            </form>
        </div>
    <?php endif; ?>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    var selectAllButton = document.getElementById('crux-select-all-routes');
    var unselectAllButton = document.getElementById('crux-unselect-all-routes');

    function setAllImportCheckboxes(checked) {
        var checkboxes = document.querySelectorAll('.crux-import-enabled');
        checkboxes.forEach(function (checkbox) {
            checkbox.checked = checked;
        });
    }

    if (selectAllButton) {
        selectAllButton.addEventListener('click', function () {
            setAllImportCheckboxes(true);
        });
    }

    if (unselectAllButton) {
        unselectAllButton.addEventListener('click', function () {
            setAllImportCheckboxes(false);
        });
    }
});
</script>
