<script lang="ts">

    import { telegram_back_button } from '$lib/telegram_back_button';
    import { onMount } from 'svelte';

    let _isEmulator = false
    let _isVisibleBackButton = false

    let _mode = 'dark'
    // let _mode = 'light'

    onMount(async () => {
        telegram_back_button.didMount()
        _isEmulator = telegram_back_button.isEmulator()
    })
    telegram_back_button.isVisibleStore.subscribe((value) => { 
        _isVisibleBackButton = value
    })
    function backButtonClickHandler() {
        telegram_back_button.navigate()
    }
    function themeButtonClickHandler() {
        _mode = 'dark' == _mode ? 'light' : 'dark'
    }
</script>

<svelte:head>
    {#if _isEmulator }
        {#if 'dark' == _mode}
        <style>
        body {
            --tg-color-scheme: dark;
            --tg-theme-bg-color: #17212b;
            --tg-theme-button-color: #5288c1;
            --tg-theme-button-text-color: white;
            --tg-theme-hint-color: #708499;
            --tg-theme-link-color: #6ab3f3;
            --tg-theme-secondary-bg-color: #232e3c;
            --tg-theme-text-color: #f5f5f5;
        }
        </style>
        {:else}
        <style>
        body {
            --tg-color-scheme: light;
            --tg-theme-bg-color: white;
            --tg-theme-button-color: #40a7b3;
            --tg-theme-button-text-color: white;
            --tg-theme-hint-color: #9999999;
            --tg-theme-link-color: #168acd;
            --tg-theme-secondary-bg-color: #f1f1f1;
            --tg-theme-text-color: black;
        }
        </style>
        {/if}
    {/if}
</svelte:head>

{#if _isEmulator}
<div class="main" >
    {#if _isVisibleBackButton}
    <button class="backButton" on:click={backButtonClickHandler}>
        <div class="arrow"></div>
        <div class="caption">Back</div>
    </button>
    {/if}
    <div class="title">
        <div>MiniApp</div>
        <div>бот</div>
    </div>
    <button class="themeButton {_mode}" on:click={themeButtonClickHandler}>
        <div class="icon"></div>
    </button>
</div>
{/if}

<style>
    .main {
        height: 60px;
        display: flex;
        justify-content: center;
        align-items: center;
        position: relative;
    }
    button {
        border-style: none;
        border-color: none;
        border-image: none;
        padding-block: 0;
        padding-inline: 0;
        border-width: 0;
        background-color: transparent;
    }
    .backButton {
        font-size: 1rem;
        cursor: pointer;
        position: absolute;
        top: 1rem;
        left: 1rem;
        display: flex;
        align-items: center;
        color: var(--tg-theme-link-color);
    }
    .backButton .arrow {
        height: 1.2rem;
        width: 0.7rem;
        margin-right: 0.4rem;
        background-color: var(--tg-theme-link-color);
        -webkit-mask-image: url("/back.svg");
    }
    .themeButton {
        position: absolute;
        top: 1rem;
        right: 1rem;
        width: 2.5rem;
        height: 1.4rem;
        border-radius: 1rem;
        display: flex;
        align-items: center;
    }
    .themeButton.dark {
        justify-content: right;
        border: 1px solid var(--tg-theme-hint-color);
    }
    .themeButton.light {
        justify-content: left;
        border: 1px solid var(--tg-theme-text-color);
    }
    .themeButton.dark .icon {
        width: 1rem;
        height: 1rem;
        margin-right: 2px;
        background-color: var(--tg-theme-hint-color);
        -webkit-mask-image: url("/dark-mode.svg");
    }
    .themeButton.light .icon {
        width: 0.9rem;
        height: 0.9rem;
        margin-left: 4px;
        background-color: var(--tg-theme-text-color);
        -webkit-mask-image: url("/light-mode.svg");
    }
    .title div:first-of-type {
        font-weight: bold;
        margin-bottom: 2px;
        color: var(--tg-theme-text-color);
    }
    .title div:last-of-type {
        text-align: center;
        font-size: smaller;
        color: var(--tg-theme-hint-color);
    }
</style>
