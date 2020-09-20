'use strict';
angular.module('main.config', [])
    .constant('GFECLIENT_CONFIG', {
        "userAgent": "NVIDIAGFEClient",
        "windowName": "gfeclient",
        "mode": "prod",
        "jarvis": {
            "server": "https://accounts.nvgs.nvidia.com",
            "version": "1",
            "deviceId": "gfeclient",
            "clientId": "135333107684344109",
            "clientDescription": "GFE {VERSION}",
            "redirectUrl": "https://rds-assets.nvidia.com/main/redirect/gfe-redirect.html#",
            "defaultTimeout": 10000,
            "defaultRetries": 2,
            "defaultTimeBetweenRetries": 500
        },
        "gfwsl": {
            "server": "https://gfwsl.geforce.com/",
            "defaultRetries": 2,
            "defaultTimeout": 10000
        },
        "gfservices": {
            "server": "https://services.gfe.nvidia.com/GFE/",
            "version": "v1.0"
        },
        "imageFormatService": {
            "server": "https://images.nvidiagrid.net/"
        },
        "jsEvents": {
            "server": "https://events.gfe.nvidia.com",
            "version": "v1.0",
            "schemaVersion": "1.20",
            "defaultRetries": 2,
            "defaultTimeBetweenRetries": 1000,
            "defaultTimeout": 30000,
            "msBetweenSendRequest": 5000,
            "maxEventsPerRequest": 128
        },
        "cms": {
            "defaultRetries": 2
        },
        "nodeService": {
            "reconnection": true,
            "reconnectionDelay": 1000,
            "reconnectionDelayMax": 1000,
            "reconnectionAttempts": 20
        },
        "rds": {
            "clientId": "b7e85bb1-afe6-4867-b11f-a32a58b7f797",
            "portalRealm": "831c3b05-4aee-4060-998f-e67cc375c35f"
        },
        "loginOptions": {
            "US": ["facebook", "google"]
        },
        "newsletter": {
            "checked": ["US"]
        },
        "minResolution": {
            "width": 900,
            "height": 600
        }
    })
    .constant('GFECLIENT_BUILD_INFO', {
        "gfePackageVersion": "3.4.0.70",
        "branch": "rel_03_04",
        "branchType": "rel",
        "gfeclientVersion": "0.1.0",
        "gitHash": "dc5d6dda4f",
        "buildType": "prod"
    });