<script lang="ts">

    // >>>>>>> Telegram Back/Main buttons emulation 

    function adjustMainButton() {
        telegram_main_button.hideButton()
        // telegram_main_button.showButton('Continue', function() { 
        //     telegram_main_button.hideButton()
        // })
    }

    import { onMount, onDestroy  } from 'svelte';
    import { telegram_back_button } from '$lib/telegram_back_button';
    import { telegram_main_button } from '$lib/telegram_main_button';
    import { goto } from '$app/navigation'; 
    import { page, navigating } from '$app/stores';

    onMount(async () => {
        telegram_back_button.didMount()
        telegram_main_button.didMount()
        adjustMainButton()
    });

    onDestroy((() => { 
        const unsubscribe = navigating.subscribe((value) => {
            if ($navigating) {
                if ($navigating.to.route.id == $page.route.id) {
                    adjustMainButton()
                }
                if ($navigating.from.route.id == $page.route.id && ['goto', 'link'].includes($navigating.type)) {
                    telegram_back_button.push($page.route.id)
                }
            }
        })
        return unsubscribe
    })())

    // <<<<<<< Telegram Back/Main buttons emulation 

    import { storable } from '$lib/storable';

    const description = storable('description', '');

	import Link from "$lib/Link.svelte"
    // let description

</script>

<svelte:head>
	<title>todo::new</title>
	<meta name="description" content="todo::new" />
</svelte:head>

<div class="container">
    <h2>ToDo::New</h2>
    <form>
        <label for="input">Description</label>
        <input id="input" bind:value={$description}/>
    </form>

    <label>Priority</label>
    <ul>
        <li><Link href="/new/priority/must" class="item">Must</Link></li>
        <li><Link href="/new/priority/should" class="item">Should</Link></li>
        <li><Link href="/new/priority/maybe" class="item">Maybe</Link></li>
    </ul>
</div>

<style>
    h2 { 
        font-size: 1.2rem;
        margin-block-start: 0;
        margin-block-end: 0.5rem;
    }
    form {
        margin-top: 16px;
        display: flex;
        flex-direction: column;
    }
    form > * {
        display: block;
        margin-bottom: 0.5rem;
    }
    input {
        height: 1.8rem;
        border-radius: 0.4rem;
        font-size: 1rem;
        padding: 0 0.5rem;
    }
    div > label {
        margin-top: 1rem;
        display: block;
    }
    ul {
        margin-block-start: 0;
        padding-inline-start: 0;
    }
    ul > li {
        list-style-type: none;
        margin-top: 1.2rem;
    }
</style>
