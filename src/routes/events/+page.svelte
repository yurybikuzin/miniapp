<script lang="ts">
	import Link from "$lib/Link.svelte"


    import { onMount, onDestroy } from 'svelte';
    import { telegram_main_button } from '$lib/telegram_main_button';
    import { telegram_back_button } from '$lib/telegram_back_button';
    import { page, navigating } from '$app/stores';

    import { goto } from '$app/navigation'; // https://stackoverflow.com/questions/68187584/how-to-route-programmatically-in-sveltekit

    onMount(async () => {
        telegram_back_button.didMount()

        telegram_main_button.didMount()
        telegram_main_button.showButton('Создать новое', function() { 
            goto('/events/new/Классика_or_Пляжка') 
        })
    })

    onDestroy((() => { 
        const unsubscribe = navigating.subscribe((value) => {
            if ($navigating) {
                // console.log('events', $page)
                if ('goto' == $navigating.type && $navigating.from.route.id == $page.route.id) {
                    telegram_back_button.push($page.route.id)
                } else {
                    console.warn('events', $navigating)
                }
                // const to_field = $navigating.to.params.field;
                // if ('link' == $navigating.type && $navigating.to.params.field) {
                //     console.log('$navigating.to.params.field', to_field)
                //     let from_field = $navigating.from.params.field;
                //     console.log('$navigating.from.params: ', $navigating.from.params)
                //     telegram_back_button.push('/events/new/' + (from_field || ''))
                //     from_field ||= 'Классика_or_Пляжка'
                //     console.log({from_field}, {to_field})
                //     storable_new_event.update(value => { 
                //         // console.log('storable_new_event.update::before', value)
                //         console.log('storable_new_event.update', {from_field}, {to_field})
                //         value[from_field] = to_field
                //         console.log('storable_new_event.update::after', value)
                //         return value
                //     })
                //     // console.warn('did set', from_field, 'to value', to_field)
                // } else if ('popstate' == $navigating.type) {
                //     const from_field = $navigating.from.params.field;
                //     console.log('popstate: from.params: ', $navigating.from.params)
                //     storable_new_event.update(value => { 
                //         console.log('storable_new_event.update', {from_field})
                //         delete value.from_field
                //         console.log('storable_new_event.update::after', value)
                //     })
                // }
                // storable_current_field.set(to_field)
            }
        })
        return unsubscribe
    })())

    // onMount(async () => {
    //     const mainButton = window.Telegram && window.Telegram.WebApp && window.Telegram.WebApp.MainButton
    //     const backButton = window.Telegram && window.Telegram.WebApp && window.Telegram.WebApp.BackButton
    //     if (mainButton && backButton) {
    //         mainButton.setText('Создать новое')
    //         function onLeavePage() {
    //             mainButton.offClick(mainButtonClickHandler)
    //             mainButton.hide()
    //             backButton.offClick(backButtonClickHandler)
    //             backButton.hide()
    //         }
    //         function backButtonClickHandler() {
    //             onLeavePage()
    //             routeToPage('')
    //         }
    //         function mainButtonClickHandler() {
    //             onLeavePage()
    //             routeToPage('events/new/Классика_or_Пляжка')
    //         }
    //         mainButton.onClick(mainButtonClickHandler)
    //         mainButton.show()
    //         backButton.onClick(backButtonClickHandler)
    //         backButton.show()
    //     }
    // });

</script>

<svelte:head>
	<title>events</title>
	<meta name="description" content="events" />
</svelte:head>

<div class="container">
    <h2>Мероприятия</h2>

    <div class="events">
        У Вас пока нет мероприятий
    </div>

</div>

<style>
    h2 { 
        font-size: 1.25rem;
        margin-block-start: 0;
    }
</style>
