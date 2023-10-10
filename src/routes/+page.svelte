<script>
	import Link from "$lib/Link.svelte"

    import { onMount, onDestroy } from 'svelte';
    import { telegram_main_button } from '$lib/telegram_main_button';
    import { telegram_back_button } from '$lib/telegram_back_button';
    import { page, navigating } from '$app/stores';

    onMount(async () => {
        telegram_back_button.didMount()

        telegram_main_button.didMount()
        telegram_main_button.hideButton()
    });

    onDestroy((() => { 
        const unsubscribe = navigating.subscribe((value) => {
            if ($navigating) {
                // console.log('main', $page)
                if ('link' == $navigating.type && $navigating.from.route.id == $page.route.id) {
                    telegram_back_button.push($page.route.id)
                } else {
                    console.warn('main', $navigating)
                }
            }
        })
        return unsubscribe
    })())

</script>

<svelte:head>
	<title>Start</title>
	<meta name="description" content="start"/>
</svelte:head>

<Link href="/events/" class="item">Мероприятия</Link>

<style>
</style>
