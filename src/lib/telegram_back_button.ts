// import { onMount } from 'svelte';

import { goto } from '$app/navigation'; // https://stackoverflow.com/questions/68187584/how-to-route-programmatically-in-sveltekit

import { writable } from 'svelte/store'

const _isVisibleStore = writable(false)
let _backButton
let _isEmulator: boolean = false
let _isVisible: boolean = false
let _urlStack: [string] = []
let _inNavigate: boolean = false

function _show() {
    if (_backButton) {
        _backButton.show()
    } else if (_isEmulator) {
        _isVisibleStore.set(true)
    }
    _isVisible = true
}

function _hide() {
    if (_backButton) {
        _backButton.hide()
    } else if (_isEmulator) {
        _isVisibleStore.set(false)
    }
    _isVisible = false
}

export let telegram_back_button = {
    isEmulator: () => _isEmulator,
    isVisibleStore: _isVisibleStore,
    push: function (url: string) {
        if (!_inNavigate) {
            _urlStack.push(url);
            console.log('after push: _urlStack', _urlStack)
            _show()
        }
    },
    navigate: function () {
        // console.warn('_navigate')
        if (_urlStack.length) {
            let url = _urlStack.pop();
            console.log('after navigate: _urlStack', _urlStack)
            _inNavigate = true
            try {
                goto(url) 
            } finally {
                _inNavigate = false
            }
            // goto(`/${route}`, { replaceState }) 
        } else {
            console.warn('TelegramBackButton.navigate failed for empty url stack', _urlStack)
        }
        if (!_urlStack.length) {
            _hide()
        }
    },
    clear: function() {
        _urlStack.clear();
        _hide()
    },
    didMount: function() {
        const web_app = window.Telegram && window.Telegram.WebApp
        _isEmulator = !(web_app && web_app.initData)

        if (!_isEmulator) {
            _backButton = web_app && web_app.BackButton
            if (_backButton && !_backButton.didInit) {
                if (_isVisible) {
                    _backButton.isVisible = _isVisible
                }
                _backButton.onClick(telegram_back_button.navigate)
                _backButton.didInit = true;
            }
        }
    }
}
// Object.defineProperty(telegram_back_button, "isVisible", {
//     get: function () {
//         return _isVisible;
//     },
//     set: function (value) {
//         if (value != _isVisible) {
//             _isVisible = value;
//             if (_backButton && _isVisible != _backButton.isVisible) {
//                 if (_isVisible) {
//                     _backButton.show()
//                 } else {
//                     _backButton.hide()
//                 }
//             }
//         }
//     },
// });

// function routeToPage(route: string, replaceState: boolean) {
//     goto(`/${route}`, { replaceState }) 
// }

// onMount(async () => {
//     console.log('onMount TelegramBackButton')
//     _backButton = window.Telegram && window.Telegram.WebApp && window.Telegram.WebApp.BackButton
//     if (_backButton) {
//         if (!_backButton.didInit) {
//             _backButton.isVisible = _isVisible;
//             _backButton.onClick(backButtonClickHandler)
//             _backButton.didInit = true;
//             console.log('_backButton.didInit')
//         }
//     }
// });
