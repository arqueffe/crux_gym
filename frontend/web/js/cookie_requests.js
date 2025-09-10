// JavaScript functions to handle HTTP requests with automatic cookie inclusion
// This allows Flutter to make requests that include HttpOnly cookies

window._makeRequestWithCookies = async function(url, method, body, headers) {
    try {
        // Convert headers from Dart object to JavaScript object
        const jsHeaders = {};
        if (headers) {
            // headers is already a JS object from Dart's jsify()
            Object.assign(jsHeaders, headers);
        }

        // Prepare fetch options
        const fetchOptions = {
            method: method,
            credentials: 'include', // This includes HttpOnly cookies automatically
            headers: jsHeaders
        };

        // Add body if provided
        if (body) {
            fetchOptions.body = body;
        }

        // Make the request
        const response = await fetch(url, fetchOptions);
        
        // Get response text
        const responseText = await response.text();
        
        // Return structured response
        return {
            status: response.status,
            statusText: response.statusText,
            data: responseText,
            ok: response.ok
        };
        
    } catch (error) {
        console.error('JavaScript request error:', error);
        return {
            status: 0,
            statusText: error.message,
            data: null,
            ok: false
        };
    }
};

// Helper function to check if cookies are available
window._checkCookies = function() {
    return document.cookie;
};

// Debug function to see what cookies are available (non-HttpOnly only)
window._debugCookies = function() {
    console.log('Available cookies (non-HttpOnly):', document.cookie);
    return document.cookie;
};
