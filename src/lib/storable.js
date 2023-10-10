// https://svelte.dev/repl/e6c0e3db7d064d43a7e4559b2862e1f7?version=3.48.0
// https://webtips.dev/webtips/svelte/how-to-read-values-of-a-store-in-svelte
import { writable, get } from 'svelte/store'
export function storable(name, initialValue) {
    const isBrowser = typeof window !== 'undefined';
    let value;
    if (isBrowser) {
        try {
            value = JSON.parse(localStorage.getItem(name));
        } catch {}
    }
    if (typeof value === 'undefined' || value === null) {
        value = initialValue
    }
    // if (isBrowser) {
    //     console.log({name, value, initialValue})
    // }
    const store = writable(value);
    const { subscribe, set, update } = store;

    return {
       subscribe,
       set: (value) => {
           if (isBrowser) {
               localStorage.setItem(name, JSON.stringify(value))
           }
           set(value);
       },
       update: (updateFn) => {
          const value = updateFn(get(store));
          if (isBrowser) {
              localStorage.setItem(name, JSON.stringify(value))
          }
          set(value);
       }
    };
}
