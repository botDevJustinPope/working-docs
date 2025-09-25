export const environment = {
    appName: 'VDS-Angular',
    production: false,
    apiUrl: 'https://dev.veodesignstudio.com/api',
    // Add other environment-specific variables here
    // For example, you might want to add a version number or feature flags
    version: '1.0.0',
    otherURLs: {
        dev: [
            'https://qa.veodesignstudio.com/api',
            'https://staging.veodesignstudio.com/api',
            'https://preview.veodesignstudio.com/api'
        ],
        prod: [
            'https://veodesignstudio.com/api',
            'https://mydesignstudio.com/api'
        ]
    }
};