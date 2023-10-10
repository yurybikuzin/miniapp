<script>
    export let href;
	// let buttonProps = {
    //     class:[$$restProps.class]
	// }
</script>

<a href="{href}" class={$$props.class}>
   <slot/>
</a>

<style>
    a {
        display: inline-block !important;
        width: 100%;
        box-sizing: border-box;
        /* font-size: 1.05rem; */
        /* font-size: 1.25rem; */
        font-size: 1.1rem;
        font-weight: 600;
        /* letter-spacing: 0.04em; */
        cursor: pointer;
        display: inline-block;
        text-decoration: none;
        border: none;
        background-color: var(--tg-theme-button-color);
        color: var(--tg-theme-button-text-color);
        padding: 0.6rem 2rem;
        border-radius: calc(1rem / 2);
        text-align: center;
    }
	/* .primary{ */
	/* 	color: blue; */
	/* } */
	/* .danger { */
	/* 	color:red; */
	/* } */
	/* .sm { */
	/* 	font-size:1em; */
	/* 	padding:0.1em; */
	/* } */
	/* .lg { */
	/* 	font-size:2em */
	/* } */
</style>
