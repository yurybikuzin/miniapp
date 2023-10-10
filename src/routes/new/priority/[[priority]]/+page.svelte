<script lang="ts">

    // >>>>>>> Telegram Back/Main buttons emulation 

    function adjustMainButton() {
        telegram_main_button.showButton('Confirm', function() { 
			const value = $todo_list
			value.push({ 
				description: $description,
				priority: priority,
				is_active: true,
				timestamp: new Date().getTime(),
			})
			description.set('')
			todo_list.set(value)
			telegram_back_button.clearStack()
        })
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

    $: priority = $page.params.priority;

    import { storable } from '$lib/storable';

    const description = storable('description', '');

    const todo_list = storable('todo_list', []);

	// import Link from "$lib/Link.svelte"
    // import { storable } from '$lib/storable';
// storable

</script>

<svelte:head>
	<title>todo::new</title>
	<meta name="description" content="todo::new" />
</svelte:head>

<div class="container">
    <h2>ToDo::New</h2>
	<div>
		You {priority} to do "{$description}" 
	</div>
</div>
<!-- <ul> -->
<!--     <li><Link href="/new/priority/must" class="item">Must</Link></li> -->
<!--     <li><Link href="/new/priority/should" class="item">Should</Link></li> -->
<!--     <li><Link href="/new/priority/maybe" class="item">Maybe</Link></li> -->
<!-- </ul> -->

<style>
    h2 { 
        font-size: 1.2rem;
        margin-block-start: 0;
        margin-block-end: 0.5rem;
    }
    /* ul { */
    /*     margin-block-start: 0; */
    /*     padding-inline-start: 0; */
    /* } */
    /* ul > li { */
    /*     list-style-type: none; */
    /*     margin-top: 1.5rem; */
    /* } */
</style>
