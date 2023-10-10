
import { writable } from 'svelte/store'

const _isVisibleStore = writable(false)
let _mainButton
let _isEmulator: boolean = false
let _isVisible: boolean = false
let _text: string = ''
let _cb: () => void

export let telegram_main_button = {
    isEmulator: () => _isEmulator,
    isVisibleStore: _isVisibleStore,
    text: () => _isEmulator ? _text : undefined,
    cb: () => _isEmulator ? _cb : undefined,
    showButton: function(text: string, cb: () => void) {
        _cb = cb
        if (_mainButton) {
            _mainButton.setParams({ text, is_visible: true })
        } else if (_isEmulator) {
            _text = text
            _isVisibleStore.set(false)
            _isVisibleStore.set(true)
        }
        _isVisible = true
    },
    hideButton: function() {
        if (_mainButton) {
            _mainButton.hide()
        } else if (_isEmulator) {
            _isVisibleStore.set(false)
        }
        _isVisible = false
    },
    didMount: function() {
        const web_app = window.Telegram && window.Telegram.WebApp
        _isEmulator = !(web_app && web_app.initData)

        if (!_isEmulator) {
            _mainButton = web_app && web_app.MainButton
            if (_mainButton && !_mainButton.didInit) {
                if (_isVisible) {
                    _mainButton.setParams({ 
                        text: _text, 
                        is_visible: true, 
                    })
                }
                _mainButton.isVisible = _isVisible
                _mainButton.onClick(() => _cb && _cb())
                _mainButton.didInit = true
            } 
        }
    },
}

