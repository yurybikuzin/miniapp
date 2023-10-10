<script lang="ts">
    import { telegram_main_button } from '$lib/telegram_main_button';
    import { onMount } from 'svelte';
    import { storable } from '$lib/storable';

    let _isEmulator = false
    let _isVisible = false
    let _text

    onMount(async () => {
        telegram_main_button.didMount()
        _isEmulator = telegram_main_button.isEmulator()
    });
    telegram_main_button.isVisibleStore.subscribe((value) => { 
        _isVisible = value
        if (value) {
            _text = telegram_main_button.text()
        }
    })
    function clickHandler() {
        telegram_main_button.cb()()
    }
</script>

{#if _isEmulator && _isVisible}
<div class="main">
    <button on:click={clickHandler}
    >{_text}</button>
</div>
{/if}

<style>
    .main {
        text-align: center;
        display: flex;
    }

    button {
        flex: 1 1 auto;
        background-color: var(--tg-theme-button-color);
        color: var(--tg-theme-button-text-color);
        border-style: none;
        border-color: none;
        border-image: none;
        padding-block: 0;
        padding-inline: 0;
        border-width: 0;
        padding: 0.6rem 2rem;
        border-radius: calc(1rem / 2);
        font-size: 1.1rem;
        font-weight: 600;
        margin: calc(1rem / 2);
        pointer: cursor;
    }
</style>

