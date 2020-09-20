// Copyright (c) 2016, NVIDIA CORPORATION.  All rights reserved.
//
// NVIDIA CORPORATION and its licensors retain all intellectual property
// and proprietary rights in and to this software, related documentation
// and any modifications thereto.  Any use, reproduction, disclosure or
// distribution of this software and related documentation without an express
// license agreement from NVIDIA CORPORATION is strictly prohibited.

'use strict'

var api = require('./NvGameStreamAPINode.node');


//! Helper function that receives body of POST request and calls callback for that data.
//! @param req      Request object provided by Express.
//! @param callback Callback that is triggered on succesfully downloaded data.
function getPostDataAndDo(req, callback) {
    var content = ''

    function onData(data) {
        content += data;
    }

    function onEnd() {
        callback(content);
    }

    req.on('data', onData);
    req.on('end', onEnd);
}

//! Helper function that receives JSON body of POST request and calls callback for the parsed data.
//! @param req      Request object provided by Express.
//! @param res      Response object provided by Express.
//! @param callback Callback that is triggered on succesfully parsed data.
function getJSONDataAndDo(req, res, callback) {
    function parseAndCallback(content) {
        var parsed = {};
        try {
            parsed = JSON.parse(content);
        }
        catch (e) {
            res.writeHead(400, { 'Content-Type': 'text/html;charset=utf-8' });
            res.end(e.name + ': ' + e.message);
            return;
        }
        callback(parsed);
    }
    getPostDataAndDo(req, parseAndCallback);
}

//! Formats the error and makes a reply with appropriate HTTP code.
//! @param res Response object provided by Express.
//! @param err Error object.
function replyWithError(res, err, httpCode) {
    if (httpCode) {
        res.writeHead(httpCode, { 'Content-Type': 'text/html;charset=utf-8' });
    }
    else if ('InvalidArgument' in err) {
        res.writeHead(400, { 'Content-Type': 'text/html;charset=utf-8' });
    }
    else if ('Not Found' in err) {
        res.writeHead(404, { 'Content-Type': 'text/html;charset=utf-8' });
    }
    else {
        res.writeHead(500, { 'Content-Type': 'text/html;charset=utf-8' });
    }
    res.end(JSON.stringify(err));
}

module.exports = function (app, io, logger) {
    if (app === undefined || io === undefined) {
        throw 'You need to provide express app and socket io';
    }

    function onGetServerStatus(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        try {
            api.GetServerStatus(doReply);
        }
        catch (err) {
            replyWithError(res, err);
            logger.error(err);
        }
    }
    app.get('/GameStream/v.1.0/ServerStatus', onGetServerStatus);


    function onSetServerStatus(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        getJSONDataAndDo(req, res, function (content) {
            try {
                api.SetServerStatus(doReply, content);
            }
            catch (err) {
                replyWithError(res, err);
                logger.error(err);
            }
        });
    }
    app.post('/GameStream/v.1.0/ServerStatus', onSetServerStatus);


    function onSetWebServiceAuthTokens(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200);
                res.end();
            }
        }

        getJSONDataAndDo(req, res, function (content) {
            try {
                api.SetWebServiceAuthTokens(doReply, content);
            }
            catch (err) {
                replyWithError(res, err);
                logger.error(err);
            }
        });
    }
    app.post('/GameStream/v.1.0/WebServiceAuthTokens', onSetWebServiceAuthTokens);


    function onGetPairedDevices(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        try {
            api.GetPairedDevices(doReply);
        }
        catch (err) {
            replyWithError(res, err);
            logger.error(err);
        }
    }
    app.get('/GameStream/v.1.0/PairedDevices', onGetPairedDevices);

    function onRemovePairedDevices(req, res) {

        function doReply(err) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200);
                res.end();
            }
        }

        try {
            api.RemovePairedDevices(doReply);
        }
        catch (err) {
            replyWithError(res, err);
            logger.error(err);
        }
    }
    app.delete('/GameStream/v.1.0/PairedDevices', onRemovePairedDevices);

    function onAddAppCollectorItem(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        getJSONDataAndDo(req, res, function (content) {
            try {
                api.AddAppCollectorItem(doReply, content);
            }
            catch (err) {
                replyWithError(res, err);
				logger.error(err);
            }
        });
    }
    app.post('/AppCollector/v.1.0/Add', onAddAppCollectorItem);

    function onEditAppCollectorItem(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        getJSONDataAndDo(req, res, function (content) {
            try {
                api.EditAppCollectorItem(doReply, content);
            }
            catch (err) {
                replyWithError(res, err);
                logger.error(err);
            }
        });
    }
    app.post('/AppCollector/v.1.0/Edit', onEditAppCollectorItem);

    function onRemoveAppCollectorItem(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        getJSONDataAndDo(req, res, function (content) {
            try {
                api.RemoveAppCollectorItem(doReply, content);
            }
            catch (err) {
                replyWithError(res, err);
                logger.error(err);
            }
        });
    }
    app.post('/AppCollector/v.1.0/Remove', onRemoveAppCollectorItem);

    function onGetAppCollectorItemList(req, res) {

        function doReply(err, data) {
            if (err) {
                replyWithError(res, err);
            }
            else {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify(data));
            }
        }

        try {
            api.GetAppCollectorItemList(doReply);
        }
        catch (err) {
            replyWithError(res, err);
            logger.error(err);
        }
    }
    app.get('/AppCollector/v.1.0/AppsList', onGetAppCollectorItemList);

    function EmitNotification(name, data) {
        setImmediate(function () { io.emit(name, data); });
    }

    function NotificationCallback(data) {
        EmitNotification('/GameStream/v.1.0/Notification', data);
    }
    api.SetNotificationCallback(NotificationCallback);

    return {
        version: function () {
            return api.GetVersion();
        },
		getStatus: function(cb){
			api.GetServerStatus(cb);
		}
    };
}
