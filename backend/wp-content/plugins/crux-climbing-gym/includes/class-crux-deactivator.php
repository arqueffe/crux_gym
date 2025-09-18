<?php

/**
 * Fired during plugin deactivation.
 */
class Crux_Deactivator {

    /**
     * Deactivate the plugin.
     *
     * Clean up temporary data, flush rewrite rules.
     * Note: We don't drop tables on deactivation, only on uninstall.
     */
    public static function deactivate() {
        // Flush rewrite rules
        flush_rewrite_rules();
        
        // Clear any transients or cached data
        delete_transient('crux_routes_cache');
        delete_transient('crux_user_stats_cache');
    }
}
