let sleep = function(second) {
    new Process().exec('C:\\Windows\\System32\\cmd.exe',['/c powershell -Command Start-Sleep -Seconds '+second])
}

let xhrGetSync = function (url) {
    var _isset = function (val) {
        if (val == undefined || val == null || (typeof val == 'number' && isNaN(val))) {
            return false;
        }
        return true
    }
    var _httpSync = function (type, url, formData, mimeType, responseType) {
        var xhr = new XMLHttpRequest();
        xhr.open(type, url, false);
        if (_isset(mimeType))
            xhr.overrideMimeType(mimeType);
        if (_isset(responseType))
            xhr.responseType = responseType;
        if (_isset(formData))
            xhr.send(formData);
        else xhr.send();
        if (xhr.status == 200) {
            return xhr.response
        }
        else {
            throw ("HTTP " + xhr.status);
        }
    }
    return _httpSync("Get", url);
}

let xhrPostSync = function (url, data) {
    var _isset = function (val) {
        if (val == undefined || val == null || (typeof val == 'number' && isNaN(val))) {
            return false;
        }
        return true
    }
    var _httpSync = function (type, url, formData, mimeType, responseType) {
        var xhr = new XMLHttpRequest();
        xhr.open(type, url, false);
        if (_isset(mimeType))
            xhr.overrideMimeType(mimeType);
        if (_isset(responseType))
            xhr.responseType = responseType;
        if (_isset(formData))
            xhr.send(formData);
        else xhr.send();
        if (xhr.status == 200) {
            return xhr.response
        }
        else {
            throw ("HTTP " + xhr.status);
        }
    }
    return _httpSync("POST", url, data);
}

tiled.webview_edit=function (content) {
    new Process().start('C:\\Windows\\System32\\cmd.exe',['/c',tiled.projectFilePath.replace(/[^/]*$/,'webview/openwebview.cmd')])
    new Process().start('C:\\Windows\\System32\\cmd.exe',['/c',tiled.projectFilePath.replace(/[^/]*$/,'webview/start.cmd')])
    xhrPostSync('http://127.0.0.1:20202/submit',JSON.stringify({status:'toedit',content:content}))
    let ret='';
    while (1) {
        ret = xhrGetSync('http://127.0.0.1:20202/query')
        try {
            ret=JSON.parse(ret)
        } catch (error) {
            
        }
        if (ret.status==='toedit') {
            sleep(1)
        } else {
            break
        }
    }
    if (ret.status==='done') {
        ret=ret.content
    } else { // ret.status==='cancel'
        ret=content
    }
    xhrGetSync('http://127.0.0.1:20202/quit')
    return ret
}

