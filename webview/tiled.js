
tiled={}
tiled.hasPushed=false;
tiled.fetch=function () {
    return fetch('/fetch')
}
tiled.push=function (content) {
    fetch('/push',{
        method: "POST", 
        body: JSON.stringify({status:'done',content:content}),
    })
    .then(r=>{tiled.hasPushed=true;window.close()})
}
tiled.cancel=function () {
    fetch('/push',{
        method: "POST", 
        body: JSON.stringify({status:'cancel'}),
    })
    .then(r=>{tiled.hasPushed=true;window.close()})
}
tiled.onunload=function () {
    if (!tiled.hasPushed) {
        navigator.sendBeacon('/push',JSON.stringify({status:'cancel'}));
    }
}

// important !!!
window.addEventListener("unload", (event) => {
    tiled.onunload()
});
