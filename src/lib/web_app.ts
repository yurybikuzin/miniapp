
export let web_app = {
    didMount: function() { 
        _isEmulator = !(window.Telegram && window.Telegram.WebApp && window.Telegram.WebApp.initData)
    },
    isEmulator: function() {
        return _isEmulator
    },
}

let _isEmulator
