import QtQuick
Image {
    id: icon
    property string name: ""
    property color tint: Theme.primary
    readonly property var drawings: ({
        clock: '<circle cx="12" cy="12" r="9"/><path d="M12 6v6l4 2"/>',
        wallpaper: '<rect x="3" y="3" width="18" height="18" rx="4"/><circle cx="8" cy="8" r="1.5"/><path d="m3 17 6-6 4 4 3-3 5 5"/>',
        palette: '<path d="M12 3a9 9 0 1 0 0 18h1.5a2 2 0 0 0 1.3-3.5c-.6-.5-.8-1.4.4-1.5h2.3A4.5 4.5 0 0 0 22 11.5C22 7 18 3 12 3z"/><circle cx="7" cy="11" r="1"/><circle cx="10" cy="7" r="1"/><circle cx="16" cy="8" r="1"/>',
        cpu: '<rect x="6" y="6" width="12" height="12" rx="2"/><rect x="9" y="9" width="6" height="6" rx="1"/><path d="M9 3v3m6-3v3M9 18v3m6-3v3M3 9h3m-3 6h3m12-6h3m-3 6h3"/>',
        memory: '<rect x="3" y="6" width="18" height="12" rx="2"/><path d="M7 10v4m5-4v4m5-4v4M7 18v3m5-3v3m5-3v3"/>',
        volume: '<path d="M11 4 6 8H3v8h3l5 4zM15 8a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14"/>',
        muted: '<path d="M11 4 6 8H3v8h3l5 4zM16 9l6 6m0-6-6 6"/>',
        battery: '<rect x="2" y="6" width="18" height="12" rx="3"/><path d="M23 10v4M6 9v6m4-6v6m4-6v6"/>',
        charging: '<path d="m13 2-8 12h6l-1 8 9-13h-7z"/>',
        plug: '<path d="M8 3v5m8-5v5M6 8h12v3a6 6 0 0 1-12 0zM12 17v5"/>',
        controls: '<path d="M4 6h16M4 12h16M4 18h16"/><circle cx="9" cy="6" r="2" fill="COLOR"/><circle cx="15" cy="12" r="2" fill="COLOR"/><circle cx="8" cy="18" r="2" fill="COLOR"/>',
        island: '<rect x="2" y="4" width="20" height="16" rx="4"/><rect x="8" y="6" width="8" height="3" rx="1.5"/>',
        restore: '<rect x="2" y="4" width="20" height="16" rx="4"/><path d="M3 9h18M6 6.5h2m3 0h2m3 0h2"/>',
        down: '<path d="m6 9 6 6 6-6"/>',
        close: '<path d="m6 6 12 12M18 6 6 18"/>',
        play: '<path d="m7 4 14 8-14 8z"/>',
        pause: '<path d="M8 4v16M16 4v16"/>',
        previous: '<path d="M5 4v16m14-16L7 12l12 8z"/>',
        next: '<path d="M19 4v16M5 4l12 8-12 8z"/>',
        music: '<path d="M9 18V5l12-3v13M9 8l12-3"/><ellipse cx="6" cy="18" rx="3" ry="3"/><ellipse cx="18" cy="15" rx="3" ry="3"/>',
        bluetooth: '<path d="m7 7 10 10-5 4V3l5 4L7 17"/>',
        network: '<path d="M3 8a15 15 0 0 1 18 0M6 12a10 10 0 0 1 12 0m-9 4a5 5 0 0 1 6 0"/><circle cx="12" cy="20" r="1"/>',
        refresh: '<path d="M20 8a8 8 0 1 0 0 8M20 3v5h-5"/>',
        plus: '<path d="M12 5v14M5 12h14"/>',
        minus: '<path d="M5 12h14"/>'
    })
    width: 18; height: 18
    sourceSize.width: width * 2; sourceSize.height: height * 2
    source: name ? 'data:image/svg+xml,' + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="' + tint + '" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">' + (drawings[name] || drawings.controls).replace(/COLOR/g, String(tint)) + '</svg>') : ''
}
