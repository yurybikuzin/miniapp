<script lang="ts">
	import Link from "$lib/Link.svelte"

    import { page, navigating } from '$app/stores';
    import { onDestroy } from 'svelte';
    import { storable } from '$lib/storable';

    import { onMount } from 'svelte';
    import { telegram_back_button } from '$lib/telegram_back_button';
    import { telegram_main_button } from '$lib/telegram_main_button';

    onMount(async () => {
        telegram_back_button.didMount()

        telegram_main_button.didMount()
        telegram_main_button.hideButton()
    });

    const storable_new_event = storable('new_event', {});
    let storable_current_field = storable('current_field', null);

    onDestroy((() => { 
        const unsubscribe = navigating.subscribe((value) => {
            if ($navigating) {
                const to_field = $navigating.to.params.field;
                if ('link' == $navigating.type && $navigating.to.params.field) {
                    console.log('$navigating.to.params.field', to_field)
                    let from_field = $navigating.from.params.field;
                    console.log('$navigating.from.params: ', $navigating.from.params)
                    telegram_back_button.push('/events/new/' + (from_field || ''))
                    from_field ||= 'Классика_or_Пляжка'
                    console.log({from_field}, {to_field})
                    storable_new_event.update(value => { 
                        // console.log('storable_new_event.update::before', value)
                        console.log('storable_new_event.update', {from_field}, {to_field})
                        value[from_field] = to_field
                        console.log('storable_new_event.update::after', value)
                        return value
                    })
                    // console.warn('did set', from_field, 'to value', to_field)
                } else if ('popstate' == $navigating.type) {
                    const from_field = $navigating.from.params.field;
                    console.log('popstate: from.params: ', $navigating.from.params)
                    storable_new_event.update(value => { 
                        console.log('storable_new_event.update', {from_field})
                        delete value.from_field
                        console.log('storable_new_event.update::after', value)
                    })
                }
                storable_current_field.set(to_field)
            }
        })
        return unsubscribe
    })())

    // let currentField;
    $: currentField = $page.params.field;

    let Классика_or_Пляжка
    $: {
        // let obj = $storable_new_event['Классика_or_Пляжка'];
        // console.log(obj)
        // Классика_or_Пляжка = obj && obj.value
        Классика_or_Пляжка = $storable_new_event['Классика_or_Пляжка']
        console.log({Классика_or_Пляжка})
    }

    let тип_мероприятия
    $: {
        // let obj = Классика_or_Пляжка && $storable_new_event[Классика_or_Пляжка]
        // console.warn(obj)
        // тип_мероприятия = obj && obj.value
        тип_мероприятия = Классика_or_Пляжка && $storable_new_event[Классика_or_Пляжка]
        console.log({тип_мероприятия})
    }

    let тип_игры
    $: {
        if (тип_мероприятия == 'Игра') {
            // let obj = $storable_new_event[тип_мероприятия]
            // тип_игры  = obj && obj.value
            тип_игры  = $storable_new_event[тип_мероприятия]
        } else {
            тип_игры = null
        }
        console.log({тип_игры})
    }

    const items = [ "Классика", "Пляжка" ]

    const items_Классика_or_Пляжка = {
        'Классика': [ "Волейбольный шаринг", "Игра", "Тренировка", "Тренировка + игра", "Турнир", "КЕМП"],
        'Пляжка': [ "Волейбольный шаринг", "Игра", "Тренировка", "Тренировка + игра", "Тренировка (профи+любитель)", "Турнир", "КЕМП"],
    }

    const items_Игра = {
        'Классика': [ "4x4", "4x2", "5x1" ],
        'Пляжка': [ "2x2", "3x3", "4x4" ],
    }

</script>

<svelte:head>
	<title>events</title>
	<meta name="description" content="events::new" />
</svelte:head>

<div class="container">
    <h2>Мероприятие::Новое</h2>
    {#if currentField == 'Классика_or_Пляжка' || !Классика_or_Пляжка}
        <ul>
            {#each items as item}
                <li><Link href={item}>{item}</Link></li>
            {/each}
        </ul>
    {:else}
        <h3>
            {Классика_or_Пляжка}{#if тип_мероприятия}::{тип_мероприятия}{#if тип_игры}::{тип_игры}{/if}
            {/if}
        </h3>
        {#if currentField == 'Классика' || currentField == 'Пляжка'}
            <ul>
                {#each items_Классика_or_Пляжка[Классика_or_Пляжка] as item}
                    <li><Link href={item}>{item}</Link></li>
                {/each}
            </ul>
        {:else if currentField == 'Игра'}
            <ul>
                {#each items_Игра[Классика_or_Пляжка] as item}
                    <li><Link href={item}>{item}</Link></li>
                {/each}
            </ul>
        {:else}
            TODO: { currentField }
        {/if}
    {/if}
</div>

<style>
    h2 { 
        font-size: 1.2rem;
        margin-block-start: 0;
        margin-block-end: 0.5rem;
    }
    h3 { 
        font-size: 1.1rem;
        margin-block-start: 0;
        margin-block-end: 0.5rem;
    }
    ul {
        list-style-type: none;
        margin-block-start: 0;
        margin-block-end: 0;
        padding-inline-start: 0;
    }
    li {
        margin-top: 1rem;
    }
    /* ul { */
    /*     list-style-type: none; */
    /*     margin-block-start: 0; */
    /*     margin-block-end: 0; */
    /*     padding-inline-start: 0; */
    /* } */
    /* li:not(:first-of-type) { */
    /*     margin-top: 1rem; */
    /* } */
</style>
