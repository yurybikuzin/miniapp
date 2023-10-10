<script lang="ts">

    // >>>>>>> Telegram Back/Main buttons emulation 

    function adjustMainButton() {
        telegram_main_button.showButton('Create new item', function() { 
            goto('/new') 
        })
    }

    import { onMount, onDestroy } from 'svelte';
    import { telegram_main_button } from '$lib/telegram_main_button';
    import { telegram_back_button } from '$lib/telegram_back_button';
    import { goto } from '$app/navigation'; 
    import { page, navigating } from '$app/stores';

    onMount(async () => {
        telegram_back_button.didMount()
        telegram_main_button.didMount()
        adjustMainButton()
    })

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
    import { derived } from "svelte/store";

    const todo_list = storable('todo_list', []);

    const is_active_as_int = is_active => is_active ? 0 : 1
    const priority_as_int = priority => 
        priority == 'must' ? 0 : priority == 'should' ? 1 : 2

    const sorted_todo_list = derived(todo_list, 
        (todo_list) => {
            let ret = Array.from(todo_list)
            ret.sort((a, b) => { 
                let ret = is_active_as_int(a.is_active) - is_active_as_int(b.is_active)
                if (ret) return ret
                ret = priority_as_int(a.priority) - priority_as_int(b.priority)
                if (ret) return ret
                return b.timestamp - a.timestamp
            })
            return ret
        }
    )

</script>

<svelte:head>
	<title>todolist</title>
	<meta name="description" content="todolist" />
</svelte:head>

<div class="container">
    <h2>To Do List</h2>
    {#if $todo_list.length}
        <ul>
            {#each $sorted_todo_list as {priority, description, is_active, timestamp}}
                <li class:is_active={is_active}>{priority} to do {description}</li>
            {/each}
        </ul>
    {:else}
        No todo item yet
    {/if}

</div>

<style>
    h2 { 
        font-size: 1.25rem;
        margin-block-start: 0;
    }
    ul {
        margin-block-start: 0;
        padding-inline-start: 0;
    }
    ul > li {
        list-style-type: none;
        margin-top: 1rem;
    }
</style>
